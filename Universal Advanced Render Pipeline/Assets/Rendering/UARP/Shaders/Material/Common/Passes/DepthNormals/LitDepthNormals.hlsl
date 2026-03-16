#ifndef URPPLUS_DEPTH_NORMALS_INCLUDED
#define URPPLUS_DEPTH_NORMALS_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthNormals/DepthNormalsVaryings.hlsl"

float3 ApplyNormals(Varyings input, float2 uv, half faceSign)
{
    #ifdef REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
        float sgn = input.tangentWS.w; // should be either +1 or -1
        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
        float3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_NormalMap, sampler_NormalMap), _NormalScale);

        #if defined(_DETAIL)
            float2 detailUV = TRANSFORM_TEX(uv, _DetailMap);
            half2 detailAG = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, detailUV).ag;
            
            half detailMask = 1.0;
            #ifdef _MASKMAP
                detailMask *= SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv).b;
            #endif

            normalTS = ApplyDetailNormal(normalTS, detailAG, _DetailNormalScale, detailMask);
        #endif

        #ifdef _DOUBLESIDED_ON
            ApplyDoubleSidedFlipOrMirror(faceSign, _DoubleSidedConstants.xyz, normalTS);
        #endif

        return TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
    #else
        return input.normalWS.xyz;
    #endif
}

#endif