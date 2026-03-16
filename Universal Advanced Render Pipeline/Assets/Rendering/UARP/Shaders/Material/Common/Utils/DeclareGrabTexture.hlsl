#ifndef URPPLUS_DECLARE_GRAB_TEXTURE_INCLUDED
#define URPPLUS_DECLARE_GRAB_TEXTURE_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

#define URPPLUS_SPECCUBE_LOD_STEPS 4

#if defined(_USE_URPPLUS_GRABPASS)
TEXTURE2D_X(_URPPlusGrabbedTexture);
SamplerState s_trilinear_clamp_sampler;

float3 SampleGrabbedColor(float2 uv, half mip)
{
    return SAMPLE_TEXTURE2D_X_LOD(_URPPlusGrabbedTexture, s_trilinear_clamp_sampler, UnityStereoTransformScreenSpaceTex(uv), mip).rgb;
}

float3 LoadGrabbedColor(uint2 uv, half mip)
{
    return LOAD_TEXTURE2D_X_LOD(_URPPlusGrabbedTexture, uv, mip).rgb;
}
#else
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

float3 SampleGrabbedColor(float2 uv, half mip)
{
    return SampleSceneColor(uv);
}

float3 LoadGrabbedColor(uint2 uv, half mip)
{
    return LoadSceneColor(uv);
}
#endif

#endif