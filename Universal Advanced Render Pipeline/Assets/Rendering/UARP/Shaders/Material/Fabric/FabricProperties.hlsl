#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
half _Surface;
half4 _DoubleSidedConstants;
half _AlphaCutoff;
half _AlphaCutoffShadow;
half _SpecularAAScreenSpaceVariance;
half _SpecularAAThreshold;

half _PPDMinSamples;
half _PPDMaxSamples;
half _PPDLodThreshold;
half4 _InvPrimScale;
half _InvTilingScale;

float4 _BaseMap_ST;
half4 _BaseColor;
half _AlphaRemapMin;
half _AlphaRemapMax;

half4 _SpecularColor;
half _Anisotropy;
half _Smoothness;
half _SmoothnessRemapMin;
half _SmoothnessRemapMax;
half _AORemapMin;
half _AORemapMax;
half _NormalScale;

float4 _HeightMap_TexelSize;
half _HeightCenter;
half _HeightAmplitude;
half _HeightOffset;
half _HeightPoMAmplitude;

float4 _ThreadMap_ST;
half _ThreadAOScale;
half _ThreadNormalScale;
half _ThreadSmoothnessScale;
half _FuzzScale;
half _FuzzIntensity;

half _Thickness;
half4 _ThicknessCurvatureRemap;

half4 _DiffusionColor;
half _TranslucencyScale;
half _TranslucencyPower;
half _TranslucencyAmbient;
half _TranslucencyDistortion;
half _TranslucencyShadows;

half4 _PuddlesFramesSize;
half _PuddlesNormalScale;
half _PuddlesSize;
half _PuddlesAnimationSpeed;
half _RainNormalScale;
half _RainSize;
half _RainAnimationSpeed;
half _RainDistortionScale;
half _RainDistortionSize;
half _RainWetnessFactor;

half4 _SnowRemap;
half4 _SnowCoverage;
half _SnowSharpness;
half _SnowSize;
half _SnowHeightAmplitude;
half _SnowHeightCenter;
half _SnowHeightMapSize;

half4 _EmissionColor;
half _EmissionScale;
half _EmissionFresnelPower;

half _HorizonFade;
half _GIOcclusionBias;

float _ComputeMeshIndex;

UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END

// NOTE: Do not ifdef the properties for dots instancing, but ifdef the actual usage.
// Otherwise you might break CPU-side as property constant-buffer offsets change per variant.
// NOTE: Dots instancing is orthogonal to the constant buffer above.
#ifdef UNITY_DOTS_INSTANCING_ENABLED

UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float , _Surface)
    UNITY_DOTS_INSTANCED_PROP(float4, _DoubleSidedConstants)
    UNITY_DOTS_INSTANCED_PROP(float , _AlphaCutoff)
    UNITY_DOTS_INSTANCED_PROP(float , _AlphaCutoffShadow)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularAAScreenSpaceVariance)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularAAThreshold)

    UNITY_DOTS_INSTANCED_PROP(float , _PPDMinSamples)
    UNITY_DOTS_INSTANCED_PROP(float , _PPDMaxSamples)
    UNITY_DOTS_INSTANCED_PROP(float , _PPDLodThreshold)
    UNITY_DOTS_INSTANCED_PROP(float4, _InvPrimScale)
    UNITY_DOTS_INSTANCED_PROP(float, _InvTilingScale)

    UNITY_DOTS_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float , _AlphaRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _AlphaRemapMax)

    UNITY_DOTS_INSTANCED_PROP(float4, _SpecularColor)
    UNITY_DOTS_INSTANCED_PROP(float , _Anisotropy)
    UNITY_DOTS_INSTANCED_PROP(float , _Smoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _NormalScale)

    UNITY_DOTS_INSTANCED_PROP(float4, _HeightMap_TexelSize)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightCenter)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightAmplitude)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightOffset)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightPoMAmplitude)

    UNITY_DOTS_INSTANCED_PROP(float , _ThreadAOScale)
    UNITY_DOTS_INSTANCED_PROP(float , _ThreadNormalScale)
    UNITY_DOTS_INSTANCED_PROP(float , _ThreadSmoothnessScale)
    UNITY_DOTS_INSTANCED_PROP(float , _FuzzScale)
    UNITY_DOTS_INSTANCED_PROP(float , _FuzzIntensity)

    UNITY_DOTS_INSTANCED_PROP(float4 , _DiffusionColor)
    UNITY_DOTS_INSTANCED_PROP(float , _Thickness)
    UNITY_DOTS_INSTANCED_PROP(float4, _ThicknessCurvatureRemap)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyScale)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyPower)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyAmbient)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyDistortion)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyShadows)
    
    UNITY_DOTS_INSTANCED_PROP(float4, _PuddlesFramesSize)
    UNITY_DOTS_INSTANCED_PROP(float , _PuddlesNormalScale)
    UNITY_DOTS_INSTANCED_PROP(float , _PuddlesSize)
    UNITY_DOTS_INSTANCED_PROP(float , _PuddlesAnimationSpeed)
    UNITY_DOTS_INSTANCED_PROP(float , _RainNormalScale)
    UNITY_DOTS_INSTANCED_PROP(float , _RainSize)
    UNITY_DOTS_INSTANCED_PROP(float , _RainAnimationSpeed)
    UNITY_DOTS_INSTANCED_PROP(float , _RainDistortionScale)
    UNITY_DOTS_INSTANCED_PROP(float , _RainDistortionSize)
    UNITY_DOTS_INSTANCED_PROP(float , _RainWetnessFactor)

    UNITY_DOTS_INSTANCED_PROP(float4, _SnowRemap)
    UNITY_DOTS_INSTANCED_PROP(float4, _SnowCoverage)
    UNITY_DOTS_INSTANCED_PROP(float , _SnowSharpness)
    UNITY_DOTS_INSTANCED_PROP(float , _SnowSize)
    UNITY_DOTS_INSTANCED_PROP(float , _SnowHeightAmplitude)
    UNITY_DOTS_INSTANCED_PROP(float , _SnowHeightCenter)
    UNITY_DOTS_INSTANCED_PROP(float , _SnowHeightMapSize)

    UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float , _EmissionScale)
    UNITY_DOTS_INSTANCED_PROP(float , _EmissionFresnelPower)
    
    UNITY_DOTS_INSTANCED_PROP(float , _HorizonFade)
    UNITY_DOTS_INSTANCED_PROP(float , _GIOcclusionBias)

    UNITY_DOTS_INSTANCED_PROP(float, _ComputeMeshIndex)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

// Define static variables to cache DOTS instanced properties
static float unity_DOTS_Sampled_Surface;
static float4 unity_DOTS_Sampled_DoubleSidedConstants;
static float unity_DOTS_Sampled_AlphaCutoff;
static float unity_DOTS_Sampled_AlphaCutoffShadow;
static float unity_DOTS_Sampled_SpecularAAScreenSpaceVariance;
static float unity_DOTS_Sampled_SpecularAAThreshold;

static float unity_DOTS_Sampled_PPDMinSamples;
static float unity_DOTS_Sampled_PPDMaxSamples;
static float unity_DOTS_Sampled_PPDLodThreshold;
static float4 unity_DOTS_Sampled_InvPrimScale;
static float unity_DOTS_Sampled_InvTilingScale;

static float4 unity_DOTS_Sampled_BaseMap_ST;
static float4 unity_DOTS_Sampled_BaseColor;
static float unity_DOTS_Sampled_AlphaRemapMin;
static float unity_DOTS_Sampled_AlphaRemapMax;

static float4 unity_DOTS_Sampled_SpecularColor;
static float unity_DOTS_Sampled_Anisotropy;
static float unity_DOTS_Sampled_Smoothness;
static float unity_DOTS_Sampled_SmoothnessRemapMin;
static float unity_DOTS_Sampled_SmoothnessRemapMax;
static float unity_DOTS_Sampled_AORemapMin;
static float unity_DOTS_Sampled_AORemapMax;
static float unity_DOTS_Sampled_NormalScale;

static float4 unity_DOTS_Sampled_HeightMap_TexelSize;
static float unity_DOTS_Sampled_HeightCenter;
static float unity_DOTS_Sampled_HeightAmplitude;
static float unity_DOTS_Sampled_HeightOffset;
static float unity_DOTS_Sampled_HeightPoMAmplitude;

static float unity_DOTS_ThreadAOScale;          
static float unity_DOTS_ThreadNormalScale;
static float unity_DOTS_ThreadSmoothnessScale;
static float unity_DOTS_FuzzScale;    
static float unity_DOTS_FuzzIntensity;

static float unity_DOTS_Thickness;
static float4 unity_DOTS_ThicknessCurvatureRemap;

static float4 unity_DOTS_DiffusionColor;
static float unity_DOTS_TranslucencyScale;
static float unity_DOTS_TranslucencyPower;
static float unity_DOTS_TranslucencyAmbient;
static float unity_DOTS_TranslucencyDistortion;
static float unity_DOTS_TranslucencyShadows;

static float4 unity_DOTS_Sampled_PuddlesFramesSize;
static float unity_DOTS_Sampled_PuddlesNormalScale;
static float unity_DOTS_Sampled_PuddlesSize;
static float unity_DOTS_Sampled_PuddlesAnimationSpeed;
static float unity_DOTS_Sampled_RainNormalScale;
static float unity_DOTS_Sampled_RainSize;
static float unity_DOTS_Sampled_RainAnimationSpeed;
static float unity_DOTS_Sampled_RainDistortionScale;
static float unity_DOTS_Sampled_RainDistortionSize;
static float unity_DOTS_Sampled_RainWetnessFactor;

static float4 unity_DOTS_Sampled_SnowRemap;
static float4 unity_DOTS_Sampled_SnowCoverage;
static float unity_DOTS_Sampled_SnowSharpness;
static float unity_DOTS_Sampled_SnowSize;
static float unity_DOTS_Sampled_SnowHeightAmplitude;
static float unity_DOTS_Sampled_SnowHeightCenter;
static float unity_DOTS_Sampled_SnowHeightMapSize;

static float4 unity_DOTS_Sampled_EmissionColor;
static float unity_DOTS_Sampled_EmissionScale;
static float unity_DOTS_Sampled_EmissionFresnelPower;

static float unity_DOTS_Sampled_HorizonFade;
static float unity_DOTS_Sampled_GIOcclusionBias;

static float unity_DOTS_Sampled_ComputeMeshIndex;

void SetupDOTSFabricMaterialPropertyCaches()
{
    unity_DOTS_Sampled_Surface                            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Surface);
    unity_DOTS_Sampled_DoubleSidedConstants               = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _DoubleSidedConstants);
    unity_DOTS_Sampled_AlphaCutoff                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaCutoff);
    unity_DOTS_Sampled_AlphaCutoffShadow                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaCutoffShadow);
    unity_DOTS_Sampled_SpecularAAScreenSpaceVariance      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SpecularAAScreenSpaceVariance);
    unity_DOTS_Sampled_SpecularAAThreshold                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SpecularAAThreshold);

    unity_DOTS_Sampled_PPDMinSamples                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _PPDMinSamples);
    unity_DOTS_Sampled_PPDMaxSamples                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _PPDMaxSamples);
    unity_DOTS_Sampled_PPDLodThreshold                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _PPDLodThreshold);
    unity_DOTS_Sampled_InvPrimScale                       = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _InvPrimScale);
    unity_DOTS_Sampled_InvTilingScale                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InvTilingScale);

    unity_DOTS_Sampled_BaseMap_ST                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseMap_ST);
    unity_DOTS_Sampled_BaseColor                          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseColor);
    unity_DOTS_Sampled_AlphaRemapMin                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMin);
    unity_DOTS_Sampled_AlphaRemapMax                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMax);

    unity_DOTS_Sampled_SpecularColor                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _SpecularColor);
    unity_DOTS_Sampled_Anisotropy                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Anisotropy);
    unity_DOTS_Sampled_Smoothness                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Smoothness);
    unity_DOTS_Sampled_SmoothnessRemapMin                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SmoothnessRemapMin);
    unity_DOTS_Sampled_SmoothnessRemapMax                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SmoothnessRemapMax);
    unity_DOTS_Sampled_AORemapMin                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AORemapMin);
    unity_DOTS_Sampled_AORemapMax                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AORemapMax);
    unity_DOTS_Sampled_NormalScale                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _NormalScale);

    unity_DOTS_Sampled_HeightMap_TexelSize                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _HeightMap_TexelSize);
    unity_DOTS_Sampled_HeightCenter                       = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightCenter);
    unity_DOTS_Sampled_HeightAmplitude                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightAmplitude);
    unity_DOTS_Sampled_HeightOffset                       = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightOffset);
    unity_DOTS_Sampled_HeightPoMAmplitude                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightPoMAmplitude);

    unity_DOTS_ThreadAOScale                              = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _ThreadAOScale);
    unity_DOTS_ThreadNormalScale                          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _ThreadNormalScale);
    unity_DOTS_ThreadSmoothnessScale                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _ThreadSmoothnessScale);
    unity_DOTS_FuzzScale                                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _FuzzScale);
    unity_DOTS_FuzzIntensity                              = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _FuzzIntensity);

    unity_DOTS_Thickness                                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Thickness);
    unity_DOTS_ThicknessCurvatureRemap                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _ThicknessCurvatureRemap);

    unity_DOTS_DiffusionColor                             = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _DiffusionColor);
    unity_DOTS_TranslucencyScale                          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _TranslucencyScale);
    unity_DOTS_TranslucencyPower                          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _TranslucencyPower);
    unity_DOTS_TranslucencyAmbient                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _TranslucencyAmbient);
    unity_DOTS_TranslucencyDistortion                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _TranslucencyDistortion);
    unity_DOTS_TranslucencyShadows                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _TranslucencyShadows);

    unity_DOTS_Sampled_PuddlesFramesSize                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _PuddlesFramesSize);
    unity_DOTS_Sampled_PuddlesNormalScale                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _PuddlesNormalScale);
    unity_DOTS_Sampled_PuddlesSize                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _PuddlesSize);
    unity_DOTS_Sampled_PuddlesAnimationSpeed              = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _PuddlesAnimationSpeed);
    unity_DOTS_Sampled_RainNormalScale                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _RainNormalScale);
    unity_DOTS_Sampled_RainSize                           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _RainSize);
    unity_DOTS_Sampled_RainAnimationSpeed                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _RainAnimationSpeed);
    unity_DOTS_Sampled_RainDistortionScale                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _RainDistortionScale);
    unity_DOTS_Sampled_RainDistortionSize                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _RainDistortionSize);
    unity_DOTS_Sampled_RainWetnessFactor                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _RainWetnessFactor);

    unity_DOTS_Sampled_SnowRemap                          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _SnowRemap);
    unity_DOTS_Sampled_SnowCoverage                       = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _SnowCoverage);
    unity_DOTS_Sampled_SnowSharpness                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SnowSharpness);
    unity_DOTS_Sampled_SnowSize                           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SnowSize);
    unity_DOTS_Sampled_SnowHeightAmplitude                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SnowHeightAmplitude);
    unity_DOTS_Sampled_SnowHeightCenter                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SnowHeightCenter);
    unity_DOTS_Sampled_SnowHeightMapSize                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SnowHeightMapSize);

    unity_DOTS_Sampled_EmissionColor                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _EmissionColor);
    unity_DOTS_Sampled_EmissionScale                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _EmissionScale);
    unity_DOTS_Sampled_EmissionFresnelPower               = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _EmissionFresnelPower);

    unity_DOTS_Sampled_HorizonFade                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HorizonFade);
    unity_DOTS_Sampled_GIOcclusionBias                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _GIOcclusionBias);

    unity_DOTS_Sampled_ComputeMeshIndex                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _ComputeMeshIndex);
}

#undef UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES
#define UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES() SetupDOTSFabricMaterialPropertyCaches()

#define _Surface                            unity_DOTS_Sampled_Surface
#define _DoubleSidedConstants               unity_DOTS_Sampled_DoubleSidedConstants
#define _AlphaCutoff                        unity_DOTS_Sampled_AlphaCutoff
#define _AlphaCutoffShadow                  unity_DOTS_Sampled_AlphaCutoffShadow
#define _SpecularAAThreshold                unity_DOTS_Sampled_SpecularAAScreenSpaceVariance
#define _SpecularAAScreenSpaceVariance      unity_DOTS_Sampled_SpecularAAThreshold

#define _PPDMinSamples                      unity_DOTS_Sampled_PPDMinSamples
#define _PPDMaxSamples                      unity_DOTS_Sampled_PPDMaxSamples
#define _PPDLodThreshold                    unity_DOTS_Sampled_PPDLodThreshold
#define _InvPrimScale                       unity_DOTS_Sampled_InvPrimScale
#define _InvTilingScale                     unity_DOTS_Sampled_InvTilingScale

#define _BaseMap_ST                         unity_DOTS_Sampled_BaseMap_ST
#define _BaseColor                          unity_DOTS_Sampled_BaseColor
#define _AlphaRemapMin                      unity_DOTS_Sampled_AlphaRemapMin
#define _AlphaRemapMax                      unity_DOTS_Sampled_AlphaRemapMax

#define _SpecularColor                      unity_DOTS_Sampled_SpecularColor
#define _Anisotropy                         unity_DOTS_Sampled_Anisotropy
#define _Smoothness                         unity_DOTS_Sampled_Smoothness
#define _SmoothnessRemapMin                 unity_DOTS_Sampled_SmoothnessRemapMin
#define _SmoothnessRemapMax                 unity_DOTS_Sampled_SmoothnessRemapMax
#define _AORemapMin                         unity_DOTS_Sampled_AORemapMin
#define _AORemapMax                         unity_DOTS_Sampled_AORemapMax
#define _NormalScale                        unity_DOTS_Sampled_NormalScale

#define _HeightMap_TexelSize                unity_DOTS_Sampled_HeightMap_TexelSize
#define _HeightCenter                       unity_DOTS_Sampled_HeightCenter
#define _HeightAmplitude                    unity_DOTS_Sampled_HeightAmplitude
#define _HeightOffset                       unity_DOTS_Sampled_HeightOffset
#define _HeightPoMAmplitude                 unity_DOTS_Sampled_HeightPoMAmplitude

#define _ThreadAOScale                      unity_DOTS_ThreadAOScale
#define _ThreadNormalScale                  unity_DOTS_ThreadNormalScale
#define _ThreadSmoothnessScale              unity_DOTS_ThreadSmoothnessScale
#define _FuzzScale                          unity_DOTS_FuzzScale
#define _FuzzIntensity                      unity_DOTS_FuzzIntensity

#define _Thickness                          unity_DOTS_Thickness
#define _ThicknessCurvatureRemap            unity_DOTS_ThicknessCurvatureRemap

#define _DiffusionColor                     unity_DOTS_DiffusionColor
#define _TranslucencyScale                  unity_DOTS_TranslucencyScale
#define _TranslucencyPower                  unity_DOTS_TranslucencyPower
#define _TranslucencyAmbient                unity_DOTS_TranslucencyAmbient
#define _TranslucencyDistortion             unity_DOTS_TranslucencyDistortion
#define _TranslucencyShadows                unity_DOTS_TranslucencyShadows

#define _PuddlesFramesSize                  unity_DOTS_Sampled_PuddlesFramesSize
#define _PuddlesNormalScale                 unity_DOTS_Sampled_PuddlesNormalScale
#define _PuddlesSize                        unity_DOTS_Sampled_PuddlesSize
#define _PuddlesAnimationSpeed              unity_DOTS_Sampled_PuddlesAnimationSpeed
#define _RainNormalScale                    unity_DOTS_Sampled_RainNormalScale
#define _RainSize                           unity_DOTS_Sampled_RainSize
#define _RainAnimationSpeed                 unity_DOTS_Sampled_RainAnimationSpeed
#define _RainDistortionScale                unity_DOTS_Sampled_RainDistortionScale
#define _RainDistortionSize                 unity_DOTS_Sampled_RainDistortionSize
#define _RainWetnessFactor                  unity_DOTS_Sampled_RainWetnessFactor

#define _SnowRemap                          unity_DOTS_Sampled_SnowRemap
#define _SnowCoverage                       unity_DOTS_Sampled_SnowCoverage
#define _SnowSharpness                      unity_DOTS_Sampled_SnowSharpness
#define _SnowSize                           unity_DOTS_Sampled_SnowSize
#define _SnowHeightAmplitude                unity_DOTS_Sampled_SnowHeightAmplitude
#define _SnowHeightCenter                   unity_DOTS_Sampled_SnowHeightCenter
#define _SnowHeightMapSize                  unity_DOTS_Sampled_SnowHeightMapSize

#define _EmissionColor                      unity_DOTS_Sampled_EmissionColor
#define _EmissionScale                      unity_DOTS_Sampled_EmissionScale
#define _EmissionFresnelPower               unity_DOTS_Sampled_EmissionFresnelPower

#define _HorizonFade                        unity_DOTS_Sampled_HorizonFade
#define _GIOcclusionBias                    unity_DOTS_Sampled_GIOcclusionBias

#define _ComputeMeshIndex                   unity_DOTS_Sampled_ComputeMeshIndex

#endif