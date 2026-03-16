#ifndef URPPLUS_FABRIC_DEPTH_NORMALS_INCLUDED
#define URPPLUS_FABRIC_DEPTH_NORMALS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthNormals/DepthNormalsVaryings.hlsl"

float3 ApplyNormals(Varyings input, float2 uv, half faceSign)
{
    #ifdef REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
        float sgn = input.tangentWS.w; // should be either +1 or -1
        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
        float3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_NormalMap, sampler_NormalMap), _NormalScale);

        #ifdef _THREADMAP
            float2 threadUV = TRANSFORM_TEX(uv, _ThreadMap);
            half2 threadAG = SAMPLE_TEXTURE2D(_ThreadMap, sampler_ThreadMap, threadUV).ag;

            normalTS = ThreadNormal(threadAG, normalTS, _ThreadNormalScale);
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