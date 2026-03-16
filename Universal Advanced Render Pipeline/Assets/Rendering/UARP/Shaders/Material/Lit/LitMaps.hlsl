#ifndef URPPLUS_LIT_MAPS_INCLUDED
#define URPPLUS_LIT_MAPS_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GlobalSamplers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"

TEXTURE2D(_BaseMap);                      SAMPLER(sampler_BaseMap);
float4 _BaseMap_TexelSize;
UNITY_TEXTURE_STREAMING_DEBUG_VARS_FOR_TEX(_BaseMap);

TEXTURE2D(_MaskMap);                      SAMPLER(sampler_MaskMap);
TEXTURE2D(_SpecularColorMap);             SAMPLER(sampler_SpecularColorMap);
TEXTURE2D(_NormalMap);                    SAMPLER(sampler_NormalMap);
TEXTURE2D(_HeightMap);                    SAMPLER(sampler_HeightMap);
TEXTURE2D(_ClearCoatMap);                 SAMPLER(sampler_ClearCoatMap);
TEXTURE2D(_CoatNormalMap);                SAMPLER(sampler_CoatNormalMap);
TEXTURE2D(_DetailMap);                    SAMPLER(sampler_DetailMap);
TEXTURE2D(_ThicknessCurvatureMap);        SAMPLER(sampler_ThicknessCurvatureMap);
TEXTURE2D(_TransmittanceColorMap);        SAMPLER(sampler_TransmittanceColorMap);
TEXTURE2D(_EmissionMap);                  SAMPLER(sampler_EmissionMap);

TEXTURE2D(_PuddlesNormal);
TEXTURE2D(_RainNormal);
TEXTURE2D(_RainDistortionMap);

TEXTURE2D(_SnowAlbedoMap);
TEXTURE2D(_SnowDetailMap);
TEXTURE2D(_SnowHeightMap);

TEXTURE2D(_WeatherMaskMap);

#if defined(_NORMALMAP)
    #define SAMPLER_NORMALMAP_IDX sampler_NormalMap
#else
    #define SAMPLER_NORMALMAP_IDX sampler_LinearRepeat
#endif

#endif