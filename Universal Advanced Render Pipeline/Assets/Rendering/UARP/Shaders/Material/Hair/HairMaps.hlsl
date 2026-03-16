#ifndef URPPLUS_HAIR_MAPS_INCLUDED
#define URPPLUS_HAIR_MAPS_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GlobalSamplers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"

TEXTURE2D(_BaseMap);                SAMPLER(sampler_BaseMap);
float4 _BaseMap_TexelSize;
UNITY_TEXTURE_STREAMING_DEBUG_VARS_FOR_TEX(_BaseMap);

TEXTURE2D(_NormalMap);              SAMPLER(sampler_NormalMap);
TEXTURE2D(_AmbientOcclusionMap);    SAMPLER(sampler_AmbientOcclusionMap);
TEXTURE2D(_SmoothnessMaskMap);      SAMPLER(sampler_SmoothnessMaskMap);

#endif