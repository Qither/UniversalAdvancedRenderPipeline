#ifndef URPPLUS_LAYERED_DEPTH_ONLY_VERTEX_INCLUDED
#define URPPLUS_LAYERED_DEPTH_ONLY_VERTEX_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/LayeredLit/LayeredDisplacement.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthOnly/Varyings.hlsl"
#if defined(UNITY_DOTS_INSTANCING_ENABLED)
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/ComputeDOTSDeformation.hlsl"
#endif

Varyings LayeredDepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

    half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
    #if defined(VERTEX_COLOR)
        vertexColor = input.vertexColor;
        output.vertexColor = input.vertexColor;
    #endif

    #if defined(UNITY_DOTS_INSTANCING_ENABLED) && defined(_COMPUTE_DOTS_DEFORMATION)
    ComputeDeformedVertex(input.vertexId, input.positionOS.xyz, input.normalOS.xyz, input.tangentOS.xyzw);
    #endif
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
    real3 positionWS = ApplyVertexDisplacementWS(vertexColor, input.positionOS.xyz, normalWS, output.uv);
    output.positionCS = TransformWorldToHClip(positionWS);
    
    return output;
}

#endif