#ifndef URPPLUS_DEFERRED_COMPLEX_LIT_TESELLATION_VERTEX_INCLUDED
#define URPPLUS_DEFERRED_COMPLEX_LIT_TESELLATION_VERTEX_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Varyings/Attributes.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Varyings/DeferredVaryings.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/VertexDisplacement.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/Tessellation/Tessellation.hlsl"

TessellationControlPoint ComplexLitGBufferPassVertex(Attributes input)
{
    TessellationControlPoint output = (TessellationControlPoint)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    // already normalized from normal transform to WS.
    output.positionOS = input.positionOS;
    output.normalOS = input.normalOS;
    output.tangentOS = input.tangentOS;
    output.texcoord = input.texcoord;

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    #ifdef DYNAMICLIGHTMAP_ON
    output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif

    return output;
}

[domain("tri")]
Varyings Domain(TessellationFactors tessFactors, const OutputPatch<TessellationControlPoint, 3> input, float3 baryCoords : SV_DomainLocation)
{
    Varyings output = (Varyings)0;
    Attributes data = (Attributes)0;

    UNITY_SETUP_INSTANCE_ID(input[0]);
    UNITY_TRANSFER_INSTANCE_ID(input[0], output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    data.positionOS = BARYCENTRIC_INTERPOLATE(positionOS); 
    data.normalOS = BARYCENTRIC_INTERPOLATE(normalOS);
    data.texcoord = BARYCENTRIC_INTERPOLATE(texcoord);
    data.tangentOS = BARYCENTRIC_INTERPOLATE(tangentOS);

    data.staticLightmapUV = BARYCENTRIC_INTERPOLATE(staticLightmapUV);
    #ifdef DYNAMICLIGHTMAP_ON
    data.dynamicLightmapUV = BARYCENTRIC_INTERPOLATE(dynamicLightmapUV);
    #endif

    #if defined(_TESSELLATION_PHONG)
        float3 p0 = TransformObjectToWorld(input[0].positionOS.xyz);
        float3 p1 = TransformObjectToWorld(input[1].positionOS.xyz);
        float3 p2 = TransformObjectToWorld(input[2].positionOS.xyz);
    
        float3 n0 = TransformObjectToWorldNormal(input[0].normalOS);
        float3 n1 = TransformObjectToWorldNormal(input[1].normalOS);
        float3 n2 = TransformObjectToWorldNormal(input[2].normalOS);
        float3 positionPredisplacementWS = TransformObjectToWorld(data.positionOS.xyz);
    
        positionPredisplacementWS = PhongTessellation(positionPredisplacementWS, p0, p1, p2, n0, n1, n2, baryCoords, _TessellationShapeFactor);
        data.positionOS = mul(unity_WorldToObject, float4(positionPredisplacementWS, 1.0));
    #endif

    output.uv = TRANSFORM_TEX(data.texcoord, _BaseMap);

    #if defined(UNITY_DOTS_INSTANCING_ENABLED) && defined(_COMPUTE_DOTS_DEFORMATION)
    ComputeDeformedVertex(data.vertexId, input.positionOS.xyz, input.normalOS.xyz, input.tangentOS.xyzw);
    #endif
    VertexNormalInputs normalInput = GetVertexNormalInputs(data.normalOS, data.tangentOS);
    VertexPositionInputs vertexInput = CalculateVertexPositionInputs(data.positionOS.xyz, normalInput.normalWS, output.uv);

    output.normalWS = normalInput.normalWS;
    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR) || (_WEATHER_ON)
        output.positionWS = vertexInput.positionWS;
    #endif

    output.positionCS = vertexInput.positionCS;

    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
        float sign = data.tangentOS.w * GetOddNegativeScale();
        output.tangentWS = half4(normalInput.tangentWS.xyz, sign);
    #endif

    OUTPUT_LIGHTMAP_UV(data.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    #ifdef DYNAMICLIGHTMAP_ON
        output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif
    OUTPUT_SH4(vertexInput.positionWS, output.normalWS.xyz, GetWorldSpaceNormalizeViewDir(vertexInput.positionWS), output.vertexSH, output.probeOcclusion);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
        output.vertexLighting = vertexLight;
    #endif

    return output;
}

#endif