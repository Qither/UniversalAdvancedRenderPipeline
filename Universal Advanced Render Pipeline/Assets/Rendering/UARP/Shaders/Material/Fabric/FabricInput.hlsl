#ifndef URPPLUS_FABRIC_INPUT_INCLUDED
#define URPPLUS_FABRIC_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Inputs/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/SubsurfaceScattering/Includes/SubsurfaceScattering.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Fabric/ThreadMapping.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Fabric/FabricProperties.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Fabric/FabricMaps.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Weather/Weather.hlsl"

#ifndef UARP_DIFFUSION_PROFILE_HASH_DECLARED
#define UARP_DIFFUSION_PROFILE_HASH_DECLARED
float _DiffusionProfileHash;
#endif

#if defined(_NORMALMAP) || defined(_THREADMAP) || defined(_RAIN_NORMALMAP)
    #define _NORMAL
#endif

#if defined(_NORMAL) || defined(_DOUBLESIDED_ON) || !defined(_MATERIAL_FEATURE_SHEEN) || defined(_PIXEL_DISPLACEMENT)
    #define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif

inline void InitializeSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    outSurfaceData = EmptyFill();

    half2 alphaRemap = half2(_AlphaRemapMin, _AlphaRemapMax);
    half4 albedoAlpha = SampleAlbedoAlpha(_BaseColor, alphaRemap, uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.albedo = albedoAlpha.rgb;
    outSurfaceData.alpha = Alpha(albedoAlpha.a, _AlphaCutoff);
    outSurfaceData.albedo = AlphaModulate(outSurfaceData.albedo, outSurfaceData.alpha);

    half4 MAODS = half4(0.0, 1.0, 1.0, _Smoothness);
    half4 metallicGlossMinMax = half4(0.0, 1.0, _SmoothnessRemapMin, _SmoothnessRemapMax);
    half2 aoMinMax = half2(_AORemapMin, _AORemapMax);
    half4 maskMap = SampleMaskMap(uv, TEXTURE2D_ARGS(_MaskMap, sampler_MaskMap), metallicGlossMinMax, aoMinMax, MAODS);

    outSurfaceData.specular = SAMPLE_TEXTURE2D(_SpecularColorMap, sampler_SpecularColorMap, uv).rgb * _SpecularColor.rgb;

    outSurfaceData.anisotropy = _Anisotropy;
    outSurfaceData.smoothness = maskMap.a;
    outSurfaceData.occlusion = maskMap.g;

    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_NormalMap, SAMPLER_NORMALMAP_IDX), _NormalScale);

    outSurfaceData.emission = SampleEmission(uv, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap),
                                                outSurfaceData.albedo, _EmissionColor.rgb, _EmissionScale);

    float2 threadUV = TRANSFORM_TEX(uv, _ThreadMap);
    #ifdef _THREADMAP
        half3 threadRemap = half3(_ThreadAOScale, _ThreadNormalScale, _ThreadSmoothnessScale);
        ApplyThreadMapping(threadUV, threadRemap, outSurfaceData);
    #endif

    #ifdef _FUZZMAP
        half fuzz = lerp(0.0h, SAMPLE_TEXTURE2D(_FuzzMap, sampler_FuzzMap, _FuzzScale * threadUV).r, _FuzzIntensity);
        outSurfaceData.albedo = saturate(outSurfaceData.albedo + fuzz.xxx);
    #endif

    half2 profileThicknessRemap = _DiffusionProfileHash != 0.0 ? (half2)GetThicknessRemapByHash(_DiffusionProfileHash) : _ThicknessCurvatureRemap.xy;

    outSurfaceData.diffusionColor = _DiffusionProfileHash != 0.0 ? (half3)GetTransmissionTintByHash(_DiffusionProfileHash) : _DiffusionColor.rgb;
    outSurfaceData.thickness = _Thickness;
    #ifdef _THICKNESSCURVATUREMAP
        half profileThickness = SAMPLE_TEXTURE2D(_ThicknessCurvatureMap, sampler_ThicknessCurvatureMap, uv).r;
        outSurfaceData.thickness = profileThicknessRemap.x + profileThickness * profileThicknessRemap.y;
    #endif
    outSurfaceData.translucencyScale = _TranslucencyScale;
    outSurfaceData.translucencyPower = 100.0h * _TranslucencyPower;
    outSurfaceData.translucencyAmbient = _TranslucencyAmbient;
    outSurfaceData.translucencyDistortion = _TranslucencyDistortion;
    outSurfaceData.translucencyShadows = _TranslucencyShadows;

    outSurfaceData.horizonFade = _HorizonFade;
    outSurfaceData.giOcclusionBias = _GIOcclusionBias;
}

#endif
