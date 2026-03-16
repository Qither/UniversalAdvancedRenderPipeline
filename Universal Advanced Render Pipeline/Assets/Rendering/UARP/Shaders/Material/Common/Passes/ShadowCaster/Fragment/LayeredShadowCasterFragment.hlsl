#ifndef URPPLUS_LAYERED_SHADOW_CASTER_FRAGMENT_INCLUDED
#define URPPLUS_LAYERED_SHADOW_CASTER_FRAGMENT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/ShadowCaster/Varyings.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/LayeredLit/LayeredDisplacement.hlsl"

#if !defined(SHADER_API_GLES)
    #define UNITY_USE_DITHER_MASK_FOR_ALPHABLENDED_SHADOWS 1
#endif

#if defined(_SURFACE_TYPE_TRANSPARENT) && defined(UNITY_USE_DITHER_MASK_FOR_ALPHABLENDED_SHADOWS)
    #define USE_DITHER_MASK 1
#endif

#ifdef USE_DITHER_MASK
    TEXTURE3D(_DitherMaskLOD); SAMPLER(sampler_DitherMaskLOD);
#endif

half4 LayeredShadowPassFragment(Varyings input) : SV_TARGET
{
    half shadowCutoff = _AlphaCutoff;
    #ifdef _SHADOW_CUTOFF
        shadowCutoff = _AlphaCutoffShadow;
    #endif

    half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
    #if defined(REQUIRE_VERTEX_COLOR)
    vertexColor = input.vertexColor;
    #endif

    LayerTexCoord layerTexCoord;
    InitializeTexCoordinates(input.uv, layerTexCoord);
    LayeredData layeredData;
    InitializeLayeredData(layerTexCoord, layeredData);

    half weights[_MAX_LAYER];
    half4 blendMasks = GetBlendMask(layerTexCoord.layerMaskUV, TEXTURE2D_ARGS(_LayerMaskMap, sampler_LayerMaskMap), vertexColor);
    ComputeLayerWeights(layeredData, blendMasks, _HeightTransition, weights);

    half alphasBlend = BlendLayeredScalar(layeredData.baseColor0.a, layeredData.baseColor1.a, layeredData.baseColor2.a, layeredData.baseColor3.a, weights);
    half alpha = Alpha(alphasBlend, shadowCutoff);

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
