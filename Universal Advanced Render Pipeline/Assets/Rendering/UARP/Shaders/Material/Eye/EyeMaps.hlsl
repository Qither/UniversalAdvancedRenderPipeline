#ifndef URPPLUS_EYE_MAPS_INCLUDED
#define URPPLUS_EYE_MAPS_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GlobalSamplers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"

//Legacy:
TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
float4 _BaseMap_TexelSize;
UNITY_TEXTURE_STREAMING_DEBUG_VARS_FOR_TEX(_BaseMap);

TEXTURE2D(_ScleraMap);          SAMPLER(sampler_ScleraMap);
TEXTURE2D(_ScleraNormalMap);    SAMPLER(sampler_ScleraNormalMap);
TEXTURE2D(_IrisMap);            SAMPLER(sampler_IrisMap);
TEXTURE2D(_IrisNormalMap);      SAMPLER(sampler_IrisNormalMap);
TEXTURE2D(_EmissionMap);        SAMPLER(sampler_EmissionMap);

#if defined(_SCLERA_NORMALMAP)
    #define SAMPLER_NORMALMAP_IDX sampler_ScleraNormalMap
#elif defined(_IRIS_NORMALMAP)
    #define SAMPLER_NORMALMAP_IDX sampler_IrisNormalMap
#else
    #define SAMPLER_NORMALMAP_IDX sampler_LinearRepeat
#endif

#endif