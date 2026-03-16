#ifndef URPPLUS_DEPTH_NORMALS_VERTEX_INCLUDED
#define URPPLUS_DEPTH_NORMALS_VERTEX_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthNormals/DepthNormalsVaryings.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/VertexDisplacement.hlsl"
#if defined(UNITY_DOTS_INSTANCING_ENABLED)
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/ComputeDOTSDeformation.hlsl"
#endif

Varyings DepthNormalsVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    
    #if defined(UNITY_DOTS_INSTANCING_ENABLED) && defined(_COMPUTE_DOTS_DEFORMATION)
    ComputeDeformedVertex(input.vertexId, input.positionOS.xyz, input.normalOS.xyz, input.tangentOS.xyzw);
    #endif
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    real3 positionWS = ApplyVertexDisplacementWS(input.positionOS.xyz, normalInput.normalWS, output.uv);

    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
    output.normalWS = half3(normalInput.normalWS);
    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
        float sign = input.tangentOS.w * float(GetOddNegativeScale());
        half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
        output.tangentWS = tangentWS;
    #endif

    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR) || defined(_PIXEL_DISPLACEMENT)
        output.positionWS = positionWS;
    #endif
    
    output.positionCS = TransformWorldToHClip(positionWS);

    return output;
}

#endif