#ifndef URPPLUS_LAYEREDLIT_MAPS_INCLUDED
#define URPPLUS_LAYEREDLIT_MAPS_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GlobalSamplers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"

TEXTURE2D(_BaseMap);                    SAMPLER(sampler_BaseMap);
TEXTURE2D(_BaseMap1);                   SAMPLER(sampler_BaseMap1);
TEXTURE2D(_BaseMap2);                   SAMPLER(sampler_BaseMap2);
TEXTURE2D(_BaseMap3);                   SAMPLER(sampler_BaseMap3);
float4 _BaseMap_TexelSize;
float4 _BaseMap1_TexelSize;
float4 _BaseMap2_TexelSize;
float4 _BaseMap3_TexelSize;
UNITY_TEXTURE_STREAMING_DEBUG_VARS_FOR_TEX(_BaseMap);
UNITY_TEXTURE_STREAMING_DEBUG_VARS_FOR_TEX(_BaseMap1);
UNITY_TEXTURE_STREAMING_DEBUG_VARS_FOR_TEX(_BaseMap2);
UNITY_TEXTURE_STREAMING_DEBUG_VARS_FOR_TEX(_BaseMap3);

TEXTURE2D(_MaskMap);                    SAMPLER(sampler_MaskMap);
TEXTURE2D(_MaskMap1);                   SAMPLER(sampler_MaskMap1);
TEXTURE2D(_MaskMap2);                   SAMPLER(sampler_MaskMap2);
TEXTURE2D(_MaskMap3);                   SAMPLER(sampler_MaskMap3);

TEXTURE2D(_NormalMap);                  SAMPLER(sampler_NormalMap);
TEXTURE2D(_NormalMap1);                 SAMPLER(sampler_NormalMap1);
TEXTURE2D(_NormalMap2);                 SAMPLER(sampler_NormalMap2);
TEXTURE2D(_NormalMap3);                 SAMPLER(sampler_NormalMap3);

TEXTURE2D(_HeightMap);                  SAMPLER(sampler_HeightMap);
TEXTURE2D(_HeightMap1);                 SAMPLER(sampler_HeightMap1);
TEXTURE2D(_HeightMap2);                 SAMPLER(sampler_HeightMap2);
TEXTURE2D(_HeightMap3);                 SAMPLER(sampler_HeightMap3);

TEXTURE2D(_DetailMap);                  SAMPLER(sampler_DetailMap);
TEXTURE2D(_DetailMap1);                 SAMPLER(sampler_DetailMap1);
TEXTURE2D(_DetailMap2);                 SAMPLER(sampler_DetailMap2);
TEXTURE2D(_DetailMap3);                 SAMPLER(sampler_DetailMap3);

TEXTURE2D(_LayerMaskMap);               SAMPLER(sampler_LayerMaskMap);
TEXTURE2D(_LayerInfluenceMaskMap);      SAMPLER(sampler_LayerInfluenceMaskMap);

TEXTURE2D(_EmissionMap);                SAMPLER(sampler_EmissionMap);

TEXTURE2D(_PuddlesNormal);
TEXTURE2D(_RainNormal);
TEXTURE2D(_RainDistortionMap);

TEXTURE2D(_SnowAlbedoMap);
TEXTURE2D(_SnowDetailMap);
TEXTURE2D(_SnowHeightMap);

TEXTURE2D(_WeatherMaskMap);

#if defined(_NORMALMAP)
    #define SAMPLER_NORMALMAP_IDX sampler_NormalMap
#elif defined(_NORMALMAP1)
    #define SAMPLER_NORMALMAP_IDX sampler_NormalMap1
#elif defined(_NORMALMAP2)
    #define SAMPLER_NORMALMAP_IDX sampler_NormalMap2
#elif defined(_NORMALMAP3)
    #define SAMPLER_NORMALMAP_IDX sampler_NormalMap3
#else
    #define SAMPLER_NORMALMAP_IDX sampler_LinearRepeat
#endif

#if defined(_DETAIL_MAP)
    #define SAMPLER_DETAILMAP_IDX sampler_DetailMap
#elif defined(_DETAIL_MAP1)
    #define SAMPLER_DETAILMAP_IDX sampler_DetailMap1
#elif defined(_DETAIL_MAP2)
    #define SAMPLER_DETAILMAP_IDX sampler_DetailMap2
#elif defined(_DETAIL_MAP3)
    #define SAMPLER_DETAILMAP_IDX sampler_DetailMap3
#else
    #define SAMPLER_DETAILMAP_IDX sampler_LinearRepeat
#endif

#if defined(_MASKMAP)
    #define SAMPLER_MASKMAP_IDX sampler_MaskMap
#elif defined(_MASKMAP1)
    #define SAMPLER_MASKMAP_IDX sampler_MaskMap1
#elif defined(_MASKMAP2)
    #define SAMPLER_MASKMAP_IDX sampler_MaskMap2
#elif defined(_MASKMAP3)
    #define SAMPLER_MASKMAP_IDX sampler_MaskMap2
#else
    #define SAMPLER_MASKMAP_IDX sampler_LinearRepeat
#endif

#if defined(_HEIGHTMAP)
    #define SAMPLER_HEIGHTMAP_IDX sampler_HeightMap
#elif defined(_HEIGHTMAP1)
    #define SAMPLER_HEIGHTMAP_IDX sampler_HeightMap1
#elif defined(_HEIGHTMAP2)
    #define SAMPLER_HEIGHTMAP_IDX sampler_HeightMap2
#elif defined(_HEIGHTMAP3)
    #define SAMPLER_HEIGHTMAP_IDX sampler_HeightMap3
#else
    #define SAMPLER_HEIGHTMAP_IDX sampler_LinearRepeat
#endif

#endif