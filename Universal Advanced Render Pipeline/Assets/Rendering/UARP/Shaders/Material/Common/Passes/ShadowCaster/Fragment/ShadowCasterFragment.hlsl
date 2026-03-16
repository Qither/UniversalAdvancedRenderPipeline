#ifndef URPPLUS_SHADOW_CASTER_PASS_INCLUDED
#define URPPLUS_SHADOW_CASTER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/ShadowCaster/Varyings.hlsl"

#if !defined(SHADER_API_GLES)
#define UNITY_USE_DITHER_MASK_FOR_ALPHABLENDED_SHADOWS 1
#endif

#if defined(_SURFACE_TYPE_TRANSPARENT) && defined(UNITY_USE_DITHER_MASK_FOR_ALPHABLENDED_SHADOWS)
#define USE_DITHER_MASK 1
#endif

#ifdef USE_DITHER_MASK
TEXTURE3D(_DitherMaskLOD); SAMPLER(sampler_DitherMaskLOD);
#endif

half4 ShadowPassFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    
    half shadowCutoff = _AlphaCutoff;
    #ifdef _SHADOW_CUTOFF
        shadowCutoff = _AlphaCutoffShadow;
    #endif

    half2 alphaRemap = half2(_AlphaRemapMin, _AlphaRemapMax);
    half albedoAlpha = SampleAlbedoAlpha(_BaseColor, alphaRemap, input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a;
    half alpha = Alpha(albedoAlpha, shadowCutoff);

    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(input.positionCS);
    #endif

    #ifdef USE_DITHER_MASK
        half alphaRef = SAMPLE_TEXTURE3D(_DitherMaskLOD, sampler_DitherMaskLOD, float3(input.positionCS.xy * 0.25, alpha * 0.9375)).a;
        clip (alphaRef - 0.01);
    #endif

    return 0;
}

#endif