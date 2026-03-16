#ifndef URPPLUS_LAYERED_META_TESSELLATION_VERTEX_INCLUDED
#define URPPLUS_LAYERED_META_TESSELLATION_VERTEX_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Meta/MetaInput.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/LayeredLit/LayeredDisplacement.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/Tessellation/Tessellation.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Meta/Varyings.hlsl"
#if defined(UNITY_DOTS_INSTANCING_ENABLED)
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/ComputeDOTSDeformation.hlsl"
#endif

TessellationControlPoint LayeredLitVertexMeta(Attributes input)
{
    TessellationControlPoint output = (TessellationControlPoint)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.positionOS = input.positionOS;
    output.normalOS = input.normalOS;
    output.uv0 = input.uv0;
    output.uv1 = input.uv1;
    output.uv2 = input.uv2;
    #if defined(VERTEX_COLOR)
    output.vertexColor = input.vertexColor;
    #endif

    return output;
}

[domain("tri")]
Varyings LayeredMetaDomain(TessellationFactors tessFactors, const OutputPatch<TessellationControlPoint, 3> input, float3 baryCoords : SV_DomainLocation)
{
    Varyings output = (Varyings)0;
    Attributes data = (Attributes)0;

    UNITY_SETUP_INSTANCE_ID(input[0]);
    UNITY_TRANSFER_INSTANCE_ID(input[0], output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    data.positionOS = BARYCENTRIC_INTERPOLATE(positionOS); 
    data.normalOS = BARYCENTRIC_INTERPOLATE(normalOS);
    data.uv0 = BARYCENTRIC_INTERPOLATE(uv0);
    data.uv1 = BARYCENTRIC_INTERPOLATE(uv1);
    data.uv2 = BARYCENTRIC_INTERPOLATE(uv2);
    #if defined(REQUIRE_VERTEX_COLOR)
    data.vertexColor = BARYCENTRIC_INTERPOLATE(vertexColor);
    #endif

    #if defined(_TESSELLATION_PHONG)
        real3 p0 = TransformObjectToWorld(input[0].positionOS.xyz);
        real3 p1 = TransformObjectToWorld(input[1].positionOS.xyz);
        real3 p2 = TransformObjectToWorld(input[2].positionOS.xyz);

        real3 n0 = TransformObjectToWorldNormal(input[0].normalOS);
        real3 n1 = TransformObjectToWorldNormal(input[1].normalOS);
        real3 n2 = TransformObjectToWorldNormal(input[2].normalOS);
        real3 positionPredisplacementWS = TransformObjectToWorld(data.positionOS.xyz);

        positionPredisplacementWS = PhongTessellation(positionPredisplacementWS, p0, p1, p2, n0, n1, n2, baryCoords, _TessellationShapeFactor);
        data.positionOS = mul(unity_WorldToObject, float4(positionPredisplacementWS, 1.0));
    #endif

    half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
    #if defined(REQUIRE_VERTEX_COLOR)
        output.vertexColor = vertexColor = data.vertexColor;
    #endif

    output.uv = TRANSFORM_TEX(data.uv0, _BaseMap);

    #if defined(UNITY_DOTS_INSTANCING_ENABLED) && defined(_COMPUTE_DOTS_DEFORMATION)
    ComputeDeformedVertex(data.vertexId, input.positionOS.xyz, input.normalOS.xyz, input.tangentOS.xyzw);
    #endif
    real3 normalWS = TransformObjectToWorldNormal(data.normalOS);
    real3 positionWS = ApplyVertexDisplacementWS(vertexColor, data.positionOS.xyz, normalWS, output.uv);
    data.positionOS = mul(unity_WorldToObject, half4(positionWS, 1.0));

    output.positionCS = MetaVertexPosition(data.positionOS, data.uv1, data.uv2, unity_LightmapST, unity_DynamicLightmapST);

    #ifdef EDITOR_VISUALIZATION
    UnityEditorVizData(data.positionOS.xyz, data.uv0, data.uv1, data.uv2, output.VizUV, output.LightCoord);
    #endif

    return output;
}

#endif