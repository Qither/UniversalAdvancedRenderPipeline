#ifndef URPPLUS_DEPTH_ONLY_TESSELLATION_VERTEX_INCLUDED
#define URPPLUS_DEPTH_ONLY_TESSELLATION_VERTEX_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/VertexDisplacement.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/Tessellation/Tessellation.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthOnly/Varyings.hlsl"
#if defined(UNITY_DOTS_INSTANCING_ENABLED)
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/ComputeDOTSDeformation.hlsl"
#endif

TessellationControlPoint DepthOnlyVertex(Attributes input)
{
    TessellationControlPoint output = (TessellationControlPoint)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.texcoord = input.texcoord;
    output.normalOS = input.normalOS;
    output.positionOS = input.positionOS;
    
    return output;
}

[domain("tri")]
Varyings DepthDomain(TessellationFactors tessFactors, const OutputPatch<TessellationControlPoint, 3> input, float3 baryCoords : SV_DomainLocation)
{
    Varyings output = (Varyings)0;
    Attributes data = (Attributes)0;

    UNITY_SETUP_INSTANCE_ID(input[0]);
    UNITY_TRANSFER_INSTANCE_ID(input[0], output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    data.positionOS = BARYCENTRIC_INTERPOLATE(positionOS); 
    data.normalOS = BARYCENTRIC_INTERPOLATE(normalOS);
    data.texcoord = BARYCENTRIC_INTERPOLATE(texcoord);

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

    output.uv = TRANSFORM_TEX(data.texcoord, _BaseMap);

    #if defined(UNITY_DOTS_INSTANCING_ENABLED) && defined(_COMPUTE_DOTS_DEFORMATION)
    ComputeDeformedVertex(data.vertexId, input.positionOS.xyz, input.normalOS.xyz, input.tangentOS.xyzw);
    #endif
    real3 normalWS = TransformObjectToWorldNormal(data.normalOS);
    real3 positionWS = ApplyVertexDisplacementWS(data.positionOS.xyz, normalWS, output.uv);
    output.positionCS = TransformWorldToHClip(positionWS);

    return output;
}

#endif