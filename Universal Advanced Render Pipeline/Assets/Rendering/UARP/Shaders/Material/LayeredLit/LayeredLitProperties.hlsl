#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
// Surface Options
half _Surface;
half4 _DoubleSidedConstants;
half _AlphaCutoff;
half _AlphaCutoffShadow;
half _SpecularAAScreenSpaceVariance;
half _SpecularAAThreshold;

// PPD
half _PPDMinSamples;
half _PPDMaxSamples;
half _PPDLodThreshold;
half4 _InvPrimScale;
half _InvTilingScale;
half _InvTilingScale1;
half _InvTilingScale2;
half _InvTilingScale3;

// Tessellation
half _TessellationFactor;
half _TessellationEdgeLength;
half _TessellationFactorMinDistance;
half _TessellationFactorMaxDistance;
half _TessellationShapeFactor;
half _TessellationBackFaceCullEpsilon;

// Surface Inputs
float4 _LayerMaskMap_ST;
half _HeightTransition;
half _LayerCount;
half _OpacityAsDensity;
half _OpacityAsDensity1;
half _OpacityAsDensity2;
half _OpacityAsDensity3;

// Base Maps
float4 _BaseMap_ST;
float4 _BaseMap1_ST;
float4 _BaseMap2_ST;
float4 _BaseMap3_ST;
half4 _BaseColor;
half4 _BaseColor1;
half4 _BaseColor2;
half4 _BaseColor3;
half _InheritBaseColor1;
half _InheritBaseColor2;
half _InheritBaseColor3;

// Alpha
half _AlphaRemapMin;
half _AlphaRemapMin1;
half _AlphaRemapMin2;
half _AlphaRemapMin3;
half _AlphaRemapMax;
half _AlphaRemapMax1;
half _AlphaRemapMax2;
half _AlphaRemapMax3;

// Metallic
half _Metallic;
half _Metallic1;
half _Metallic2;
half _Metallic3;
half _MetallicRemapMin;
half _MetallicRemapMin1;
half _MetallicRemapMin2;
half _MetallicRemapMin3;
half _MetallicRemapMax;
half _MetallicRemapMax1;
half _MetallicRemapMax2;
half _MetallicRemapMax3;

// Smoothness
half _Smoothness;
half _Smoothness1;
half _Smoothness2;
half _Smoothness3;
half _SmoothnessRemapMin;
half _SmoothnessRemapMin1;
half _SmoothnessRemapMin2;
half _SmoothnessRemapMin3;
half _SmoothnessRemapMax;
half _SmoothnessRemapMax1;
half _SmoothnessRemapMax2;
half _SmoothnessRemapMax3;

// AO
half _AORemapMin;
half _AORemapMin1;
half _AORemapMin2;
half _AORemapMin3;
half _AORemapMax;
half _AORemapMax1;
half _AORemapMax2;
half _AORemapMax3;

// Normals
half _NormalScale; 
half _NormalScale1; 
half _NormalScale2; 
half _NormalScale3;
half _InheritBaseNormal1; 
half _InheritBaseNormal2; 
half _InheritBaseNormal3;

// Height
float4 _HeightMap_TexelSize;
float4 _HeightMap1_TexelSize;
float4 _HeightMap2_TexelSize;
float4 _HeightMap3_TexelSize;
half _HeightCenter;
half _HeightCenter1;
half _HeightCenter2;
half _HeightCenter3;
half _HeightAmplitude;
half _HeightAmplitude1;
half _HeightAmplitude2;
half _HeightAmplitude3;
half _HeightPoMAmplitude;
half _HeightPoMAmplitude1;
half _HeightPoMAmplitude2;
half _HeightPoMAmplitude3;
half _InheritBaseHeight1;
half _InheritBaseHeight2;
half _InheritBaseHeight3;

// Detail Maps
float4 _DetailMap_ST;
float4 _DetailMap1_ST;
float4 _DetailMap2_ST;
float4 _DetailMap3_ST;
half _DetailAlbedoScale;
half _DetailAlbedoScale1;
half _DetailAlbedoScale2;
half _DetailAlbedoScale3;
half _DetailNormalScale;
half _DetailNormalScale1;
half _DetailNormalScale2;
half _DetailNormalScale3;
half _DetailSmoothnessScale;
half _DetailSmoothnessScale1;
half _DetailSmoothnessScale2;
half _DetailSmoothnessScale3;

// Puddles and Rain
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

// Snow
half4 _SnowRemap;
half4 _SnowCoverage;
half _SnowSharpness;
half _SnowSize;
half _SnowHeightAmplitude;
half _SnowHeightCenter;
half _SnowHeightMapSize;

// Emission
float4 _EmissionMap_ST;
half4 _EmissionColor;
half _EmissionScale;
half _EmissionFresnelPower;

// Advanced Options
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
    // Surface Options
    UNITY_DOTS_INSTANCED_PROP(float  , _Surface)
    UNITY_DOTS_INSTANCED_PROP(float4 , _DoubleSidedConstants)
    UNITY_DOTS_INSTANCED_PROP(float  , _AlphaCutoff)
    UNITY_DOTS_INSTANCED_PROP(float  , _AlphaCutoffShadow)
    UNITY_DOTS_INSTANCED_PROP(float  , _SpecularAAScreenSpaceVariance)
    UNITY_DOTS_INSTANCED_PROP(float  , _SpecularAAThreshold)

    // PPD
    UNITY_DOTS_INSTANCED_PROP(float  , _PPDMinSamples)
    UNITY_DOTS_INSTANCED_PROP(float  , _PPDMaxSamples)
    UNITY_DOTS_INSTANCED_PROP(float  , _PPDLodThreshold)
    
    UNITY_DOTS_INSTANCED_PROP(float4 , _InvPrimScale)
    UNITY_DOTS_INSTANCED_PROP(float  , _InvTilingScale)
    UNITY_DOTS_INSTANCED_PROP(float  , _InvTilingScale1)
    UNITY_DOTS_INSTANCED_PROP(float  , _InvTilingScale2)
    UNITY_DOTS_INSTANCED_PROP(float  , _InvTilingScale3)

    // Tessellation
    UNITY_DOTS_INSTANCED_PROP(float , _TessellationFactor)
    UNITY_DOTS_INSTANCED_PROP(float , _TessellationEdgeLength)
    UNITY_DOTS_INSTANCED_PROP(float , _TessellationFactorMinDistance)
    UNITY_DOTS_INSTANCED_PROP(float , _TessellationFactorMaxDistance)
    UNITY_DOTS_INSTANCED_PROP(float , _TessellationShapeFactor)
    UNITY_DOTS_INSTANCED_PROP(float , _TessellationBackFaceCullEpsilon)

    // Surface Inputs
    UNITY_DOTS_INSTANCED_PROP(float4 , _LayerMaskMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightTransition)
    UNITY_DOTS_INSTANCED_PROP(float  , _LayerCount)
    UNITY_DOTS_INSTANCED_PROP(float  , _OpacityAsDensity)
    UNITY_DOTS_INSTANCED_PROP(float  , _OpacityAsDensity1)
    UNITY_DOTS_INSTANCED_PROP(float  , _OpacityAsDensity2)
    UNITY_DOTS_INSTANCED_PROP(float  , _OpacityAsDensity3)

    // Base Maps
    UNITY_DOTS_INSTANCED_PROP(float4 , _BaseMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4 , _BaseMap1_ST)
    UNITY_DOTS_INSTANCED_PROP(float4 , _BaseMap2_ST)
    UNITY_DOTS_INSTANCED_PROP(float4 , _BaseMap3_ST)
    UNITY_DOTS_INSTANCED_PROP(float4 , _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float4 , _BaseColor1)
    UNITY_DOTS_INSTANCED_PROP(float4 , _BaseColor2)
    UNITY_DOTS_INSTANCED_PROP(float4 , _BaseColor3)
    UNITY_DOTS_INSTANCED_PROP(float, _InheritBaseColor1)
    UNITY_DOTS_INSTANCED_PROP(float, _InheritBaseColor2)
    UNITY_DOTS_INSTANCED_PROP(float, _InheritBaseColor3)

    // Alpha
    UNITY_DOTS_INSTANCED_PROP(float  , _AlphaRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float  , _AlphaRemapMin1)
    UNITY_DOTS_INSTANCED_PROP(float  , _AlphaRemapMin2)
    UNITY_DOTS_INSTANCED_PROP(float  , _AlphaRemapMin3)
    UNITY_DOTS_INSTANCED_PROP(float  , _AlphaRemapMax)
    UNITY_DOTS_INSTANCED_PROP(float  , _AlphaRemapMax1)
    UNITY_DOTS_INSTANCED_PROP(float  , _AlphaRemapMax2)
    UNITY_DOTS_INSTANCED_PROP(float  , _AlphaRemapMax3)

    // Metallic
    UNITY_DOTS_INSTANCED_PROP(float  , _Metallic)
    UNITY_DOTS_INSTANCED_PROP(float  , _Metallic1)
    UNITY_DOTS_INSTANCED_PROP(float  , _Metallic2)
    UNITY_DOTS_INSTANCED_PROP(float  , _Metallic3)
    UNITY_DOTS_INSTANCED_PROP(float  , _MetallicRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float  , _MetallicRemapMin1)
    UNITY_DOTS_INSTANCED_PROP(float  , _MetallicRemapMin2)
    UNITY_DOTS_INSTANCED_PROP(float  , _MetallicRemapMin3)
    UNITY_DOTS_INSTANCED_PROP(float  , _MetallicRemapMax)
    UNITY_DOTS_INSTANCED_PROP(float  , _MetallicRemapMax1)
    UNITY_DOTS_INSTANCED_PROP(float  , _MetallicRemapMax2)
    UNITY_DOTS_INSTANCED_PROP(float  , _MetallicRemapMax3)
    
    // Smoothness
    UNITY_DOTS_INSTANCED_PROP(float  , _Smoothness)
    UNITY_DOTS_INSTANCED_PROP(float  , _Smoothness1)
    UNITY_DOTS_INSTANCED_PROP(float  , _Smoothness2)
    UNITY_DOTS_INSTANCED_PROP(float  , _Smoothness3)
    UNITY_DOTS_INSTANCED_PROP(float  , _SmoothnessRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float  , _SmoothnessRemapMin1)
    UNITY_DOTS_INSTANCED_PROP(float  , _SmoothnessRemapMin2)
    UNITY_DOTS_INSTANCED_PROP(float  , _SmoothnessRemapMin3)
    UNITY_DOTS_INSTANCED_PROP(float  , _SmoothnessRemapMax)
    UNITY_DOTS_INSTANCED_PROP(float  , _SmoothnessRemapMax1)
    UNITY_DOTS_INSTANCED_PROP(float  , _SmoothnessRemapMax2)
    UNITY_DOTS_INSTANCED_PROP(float  , _SmoothnessRemapMax3)

    // AO
    UNITY_DOTS_INSTANCED_PROP(float  , _AORemapMin)
    UNITY_DOTS_INSTANCED_PROP(float  , _AORemapMin1)
    UNITY_DOTS_INSTANCED_PROP(float  , _AORemapMin2)
    UNITY_DOTS_INSTANCED_PROP(float  , _AORemapMin3)
    UNITY_DOTS_INSTANCED_PROP(float  , _AORemapMax)
    UNITY_DOTS_INSTANCED_PROP(float  , _AORemapMax1)
    UNITY_DOTS_INSTANCED_PROP(float  , _AORemapMax2)
    UNITY_DOTS_INSTANCED_PROP(float  , _AORemapMax3)

    // Normals
    UNITY_DOTS_INSTANCED_PROP(float  , _NormalScale)
    UNITY_DOTS_INSTANCED_PROP(float  , _NormalScale1)
    UNITY_DOTS_INSTANCED_PROP(float  , _NormalScale2)
    UNITY_DOTS_INSTANCED_PROP(float  , _NormalScale3)
    UNITY_DOTS_INSTANCED_PROP(float  , _InheritBaseNormal1)
    UNITY_DOTS_INSTANCED_PROP(float  , _InheritBaseNormal2)
    UNITY_DOTS_INSTANCED_PROP(float  , _InheritBaseNormal3)

    // Height
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightAmplitude)
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightAmplitude1)
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightAmplitude2)
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightAmplitude3)
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightCenter)
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightCenter1)
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightCenter2)
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightCenter3)
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightPoMAmplitude)
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightPoMAmplitude1)
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightPoMAmplitude2)
    UNITY_DOTS_INSTANCED_PROP(float  , _HeightPoMAmplitude3)
    UNITY_DOTS_INSTANCED_PROP(float  , _InheritBaseHeight1)
    UNITY_DOTS_INSTANCED_PROP(float  , _InheritBaseHeight2)
    UNITY_DOTS_INSTANCED_PROP(float  , _InheritBaseHeight3)

    // Detail Maps
    UNITY_DOTS_INSTANCED_PROP(float4 , _DetailMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4 , _DetailMap1_ST)
    UNITY_DOTS_INSTANCED_PROP(float4 , _DetailMap2_ST)
    UNITY_DOTS_INSTANCED_PROP(float4 , _DetailMap3_ST)
    UNITY_DOTS_INSTANCED_PROP(float  , _DetailAlbedoScale)
    UNITY_DOTS_INSTANCED_PROP(float  , _DetailAlbedoScale1)
    UNITY_DOTS_INSTANCED_PROP(float  , _DetailAlbedoScale2)
    UNITY_DOTS_INSTANCED_PROP(float  , _DetailAlbedoScale3)
    UNITY_DOTS_INSTANCED_PROP(float  , _DetailNormalScale)
    UNITY_DOTS_INSTANCED_PROP(float  , _DetailNormalScale1)
    UNITY_DOTS_INSTANCED_PROP(float  , _DetailNormalScale2)
    UNITY_DOTS_INSTANCED_PROP(float  , _DetailNormalScale3)
    UNITY_DOTS_INSTANCED_PROP(float  , _DetailSmoothnessScale)
    UNITY_DOTS_INSTANCED_PROP(float  , _DetailSmoothnessScale1)
    UNITY_DOTS_INSTANCED_PROP(float  , _DetailSmoothnessScale2)
    UNITY_DOTS_INSTANCED_PROP(float  , _DetailSmoothnessScale3)

    // Puddles and Rain
    UNITY_DOTS_INSTANCED_PROP(float4 , _PuddlesFramesSize)
    UNITY_DOTS_INSTANCED_PROP(float  , _PuddlesNormalScale)
    UNITY_DOTS_INSTANCED_PROP(float  , _PuddlesSize)
    UNITY_DOTS_INSTANCED_PROP(float  , _PuddlesAnimationSpeed)
    UNITY_DOTS_INSTANCED_PROP(float  , _RainNormalScale)
    UNITY_DOTS_INSTANCED_PROP(float  , _RainSize)
    UNITY_DOTS_INSTANCED_PROP(float  , _RainAnimationSpeed)
    UNITY_DOTS_INSTANCED_PROP(float  , _RainDistortionScale)
    UNITY_DOTS_INSTANCED_PROP(float  , _RainDistortionSize)
    UNITY_DOTS_INSTANCED_PROP(float  , _RainWetnessFactor)

    // Snow
    UNITY_DOTS_INSTANCED_PROP(float4 , _SnowRemap)
    UNITY_DOTS_INSTANCED_PROP(float4 , _SnowCoverage)
    UNITY_DOTS_INSTANCED_PROP(float  , _SnowSharpness)
    UNITY_DOTS_INSTANCED_PROP(float  , _SnowSize)
    UNITY_DOTS_INSTANCED_PROP(float  , _SnowHeightAmplitude)
    UNITY_DOTS_INSTANCED_PROP(float  , _SnowHeightCenter)
    UNITY_DOTS_INSTANCED_PROP(float  , _SnowHeightMapSize)

    // Emission
    UNITY_DOTS_INSTANCED_PROP(float4 , _EmissionMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4 , _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float  , _EmissionScale)
    UNITY_DOTS_INSTANCED_PROP(float  , _EmissionFresnelPower)

    // Advanced Options
    UNITY_DOTS_INSTANCED_PROP(float, _HorizonFade)
    UNITY_DOTS_INSTANCED_PROP(float, _GIOcclusionBias)

    UNITY_DOTS_INSTANCED_PROP(float, _ComputeMeshIndex)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

// Define static variables to cache DOTS instanced properties
// Surface Options
static float unity_DOTS_Sampled_Surface;
static float4 unity_DOTS_Sampled_DoubleSidedConstants;
static float unity_DOTS_Sampled_AlphaCutoff;
static float unity_DOTS_Sampled_AlphaCutoffShadow;
static float unity_DOTS_Sampled_SpecularAAScreenSpaceVariance;
static float unity_DOTS_Sampled_SpecularAAThreshold;

// PPD
static float unity_DOTS_Sampled_PPDMinSamples;
static float unity_DOTS_Sampled_PPDMaxSamples;
static float unity_DOTS_Sampled_PPDLodThreshold;
static float4 unity_DOTS_Sampled_InvPrimScale;
static float unity_DOTS_Sampled_InvTilingScale;
static float unity_DOTS_Sampled_InvTilingScale1;
static float unity_DOTS_Sampled_InvTilingScale2;
static float unity_DOTS_Sampled_InvTilingScale3;

// Tessellation
static float unity_DOTS_Sampled_TessellationFactor;
static float unity_DOTS_Sampled_TessellationEdgeLength;
static float unity_DOTS_Sampled_TessellationFactorMinDistance;
static float unity_DOTS_Sampled_TessellationFactorMaxDistance;
static float unity_DOTS_Sampled_TessellationShapeFactor;
static float unity_DOTS_Sampled_TessellationBackFaceCullEpsilon;

// Surface Inputs
static float4 unity_DOTS_Sampled_LayerMaskMap_ST;
static float unity_DOTS_Sampled_HeightTransition;
static float unity_DOTS_Sampled_LayerCount;
static float unity_DOTS_Sampled_OpacityAsDensity;
static float unity_DOTS_Sampled_OpacityAsDensity1;
static float unity_DOTS_Sampled_OpacityAsDensity2;
static float unity_DOTS_Sampled_OpacityAsDensity3;

// Base Maps
static float4 unity_DOTS_Sampled_BaseMap_ST;
static float4 unity_DOTS_Sampled_BaseMap1_ST;
static float4 unity_DOTS_Sampled_BaseMap2_ST;
static float4 unity_DOTS_Sampled_BaseMap3_ST;
static float4 unity_DOTS_Sampled_BaseColor;
static float4 unity_DOTS_Sampled_BaseColor1;
static float4 unity_DOTS_Sampled_BaseColor2;
static float4 unity_DOTS_Sampled_BaseColor3;
static float unity_DOTS_Sampled_InheritBaseColor1;
static float unity_DOTS_Sampled_InheritBaseColor2;
static float unity_DOTS_Sampled_InheritBaseColor3;

// Alpha
static float unity_DOTS_Sampled_AlphaRemapMin;
static float unity_DOTS_Sampled_AlphaRemapMin1;
static float unity_DOTS_Sampled_AlphaRemapMin2;
static float unity_DOTS_Sampled_AlphaRemapMin3;
static float unity_DOTS_Sampled_AlphaRemapMax;
static float unity_DOTS_Sampled_AlphaRemapMax1;
static float unity_DOTS_Sampled_AlphaRemapMax2;
static float unity_DOTS_Sampled_AlphaRemapMax3;

// Metallic
static float unity_DOTS_Sampled_Metallic;
static float unity_DOTS_Sampled_Metallic1;
static float unity_DOTS_Sampled_Metallic2;
static float unity_DOTS_Sampled_Metallic3;
static float unity_DOTS_Sampled_MetallicRemapMin;
static float unity_DOTS_Sampled_MetallicRemapMin1;
static float unity_DOTS_Sampled_MetallicRemapMin2;
static float unity_DOTS_Sampled_MetallicRemapMin3;
static float unity_DOTS_Sampled_MetallicRemapMax;
static float unity_DOTS_Sampled_MetallicRemapMax1;
static float unity_DOTS_Sampled_MetallicRemapMax2;
static float unity_DOTS_Sampled_MetallicRemapMax3;

// Smoothness
static float unity_DOTS_Sampled_Smoothness;
static float unity_DOTS_Sampled_Smoothness1;
static float unity_DOTS_Sampled_Smoothness2;
static float unity_DOTS_Sampled_Smoothness3;
static float unity_DOTS_Sampled_SmoothnessRemapMin;
static float unity_DOTS_Sampled_SmoothnessRemapMin1;
static float unity_DOTS_Sampled_SmoothnessRemapMin2;
static float unity_DOTS_Sampled_SmoothnessRemapMin3;
static float unity_DOTS_Sampled_SmoothnessRemapMax;
static float unity_DOTS_Sampled_SmoothnessRemapMax1;
static float unity_DOTS_Sampled_SmoothnessRemapMax2;
static float unity_DOTS_Sampled_SmoothnessRemapMax3;

// AO
static float unity_DOTS_Sampled_AORemapMin;
static float unity_DOTS_Sampled_AORemapMin1;
static float unity_DOTS_Sampled_AORemapMin2;
static float unity_DOTS_Sampled_AORemapMin3;
static float unity_DOTS_Sampled_AORemapMax;
static float unity_DOTS_Sampled_AORemapMax1;
static float unity_DOTS_Sampled_AORemapMax2;
static float unity_DOTS_Sampled_AORemapMax3;

// Normals
static float unity_DOTS_Sampled_NormalScale;
static float unity_DOTS_Sampled_NormalScale1;
static float unity_DOTS_Sampled_NormalScale2;
static float unity_DOTS_Sampled_NormalScale3;
static float unity_DOTS_Sampled_InheritBaseNormal1;
static float unity_DOTS_Sampled_InheritBaseNormal2;
static float unity_DOTS_Sampled_InheritBaseNormal3;

// Height
static float unity_DOTS_Sampled_HeightAmplitude;
static float unity_DOTS_Sampled_HeightAmplitude1;
static float unity_DOTS_Sampled_HeightAmplitude2;
static float unity_DOTS_Sampled_HeightAmplitude3;
static float unity_DOTS_Sampled_HeightCenter;
static float unity_DOTS_Sampled_HeightCenter1;
static float unity_DOTS_Sampled_HeightCenter2;
static float unity_DOTS_Sampled_HeightCenter3;
static float unity_DOTS_Sampled_HeightPoMAmplitude;
static float unity_DOTS_Sampled_HeightPoMAmplitude1;
static float unity_DOTS_Sampled_HeightPoMAmplitude2;
static float unity_DOTS_Sampled_HeightPoMAmplitude3;
static float unity_DOTS_Sampled_InheritBaseHeight1;
static float unity_DOTS_Sampled_InheritBaseHeight2;
static float unity_DOTS_Sampled_InheritBaseHeight3;

// Detail Maps
static float4 unity_DOTS_Sampled_DetailMap_ST;
static float4 unity_DOTS_Sampled_DetailMap1_ST;
static float4 unity_DOTS_Sampled_DetailMap2_ST;
static float4 unity_DOTS_Sampled_DetailMap3_ST;
static float unity_DOTS_Sampled_DetailAlbedoScale;
static float unity_DOTS_Sampled_DetailAlbedoScale1;
static float unity_DOTS_Sampled_DetailAlbedoScale2;
static float unity_DOTS_Sampled_DetailAlbedoScale3;
static float unity_DOTS_Sampled_DetailNormalScale;
static float unity_DOTS_Sampled_DetailNormalScale1;
static float unity_DOTS_Sampled_DetailNormalScale2;
static float unity_DOTS_Sampled_DetailNormalScale3;
static float unity_DOTS_Sampled_DetailSmoothnessScale;
static float unity_DOTS_Sampled_DetailSmoothnessScale1;
static float unity_DOTS_Sampled_DetailSmoothnessScale2;
static float unity_DOTS_Sampled_DetailSmoothnessScale3;

// Puddles and Rain
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

// Snow
static float4 unity_DOTS_Sampled_SnowRemap;
static float4 unity_DOTS_Sampled_SnowCoverage;
static float unity_DOTS_Sampled_SnowSharpness;
static float unity_DOTS_Sampled_SnowSize;
static float unity_DOTS_Sampled_SnowHeightAmplitude;
static float unity_DOTS_Sampled_SnowHeightCenter;
static float unity_DOTS_Sampled_SnowHeightMapSize;

// Emission
static float4 unity_DOTS_Sampled_EmissionMap_ST;
static float4 unity_DOTS_Sampled_EmissionColor;
static float unity_DOTS_Sampled_EmissionScale;
static float unity_DOTS_Sampled_EmissionFresnelPower;

// Advanced Options
static float unity_DOTS_Sampled_HorizonFade;
static float unity_DOTS_Sampled_GIOcclusionBias;

static float unity_DOTS_Sampled_ComputeMeshIndex;

void SetupDOTSLayeredLitMaterialPropertyCaches()
{
    // Surface Options
    unity_DOTS_Sampled_Surface                            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Surface);
    unity_DOTS_Sampled_DoubleSidedConstants               = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _DoubleSidedConstants);
    unity_DOTS_Sampled_AlphaCutoff                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaCutoff);
    unity_DOTS_Sampled_AlphaCutoffShadow                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaCutoffShadow);
    unity_DOTS_Sampled_SpecularAAScreenSpaceVariance      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SpecularAAScreenSpaceVariance);
    unity_DOTS_Sampled_SpecularAAThreshold                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SpecularAAThreshold);

    // PPD
    unity_DOTS_Sampled_PPDMinSamples                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _PPDMinSamples);
    unity_DOTS_Sampled_PPDMaxSamples                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _PPDMaxSamples);
    unity_DOTS_Sampled_PPDLodThreshold                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _PPDLodThreshold);
    unity_DOTS_Sampled_InvPrimScale                       = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _InvPrimScale);
    unity_DOTS_Sampled_InvTilingScale                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InvTilingScale);
    unity_DOTS_Sampled_InvTilingScale1                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InvTilingScale1);
    unity_DOTS_Sampled_InvTilingScale2                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InvTilingScale2);
    unity_DOTS_Sampled_InvTilingScale3                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InvTilingScale3);

    // Tessellation
    unity_DOTS_Sampled_TessellationFactor                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _TessellationFactor);
    unity_DOTS_Sampled_TessellationEdgeLength             = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _TessellationEdgeLength);
    unity_DOTS_Sampled_TessellationFactorMinDistance      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _TessellationFactorMinDistance);
    unity_DOTS_Sampled_TessellationFactorMaxDistance      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _TessellationFactorMaxDistance);
    unity_DOTS_Sampled_TessellationShapeFactor            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _TessellationShapeFactor);
    unity_DOTS_Sampled_TessellationBackFaceCullEpsilon    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _TessellationBackFaceCullEpsilon);

    // Surface Inputs
    unity_DOTS_Sampled_LayerMaskMap_ST                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _LayerMaskMap_ST);
    unity_DOTS_Sampled_HeightTransition                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightTransition);
    unity_DOTS_Sampled_LayerCount                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _LayerCount);
    unity_DOTS_Sampled_OpacityAsDensity                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _OpacityAsDensity);
    unity_DOTS_Sampled_OpacityAsDensity1                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _OpacityAsDensity1);
    unity_DOTS_Sampled_OpacityAsDensity2                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _OpacityAsDensity2);
    unity_DOTS_Sampled_OpacityAsDensity3                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _OpacityAsDensity3);

    // Base Maps
    unity_DOTS_Sampled_BaseMap_ST                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseMap_ST);
    unity_DOTS_Sampled_BaseMap1_ST                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseMap1_ST);
    unity_DOTS_Sampled_BaseMap2_ST                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseMap2_ST);
    unity_DOTS_Sampled_BaseMap3_ST                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseMap3_ST);
    unity_DOTS_Sampled_BaseColor                          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseColor);
    unity_DOTS_Sampled_BaseColor1                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseColor1);
    unity_DOTS_Sampled_BaseColor2                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseColor2);
    unity_DOTS_Sampled_BaseColor3                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseColor3);
    unity_DOTS_Sampled_InheritBaseColor1                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InheritBaseColor1);
    unity_DOTS_Sampled_InheritBaseColor2                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InheritBaseColor2);
    unity_DOTS_Sampled_InheritBaseColor3                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InheritBaseColor3);

    // Alpha
    unity_DOTS_Sampled_AlphaRemapMin                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMin);
    unity_DOTS_Sampled_AlphaRemapMin1                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMin1);
    unity_DOTS_Sampled_AlphaRemapMin2                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMin2);
    unity_DOTS_Sampled_AlphaRemapMin3                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMin3);
    unity_DOTS_Sampled_AlphaRemapMax                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMax);
    unity_DOTS_Sampled_AlphaRemapMax1                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMax1);
    unity_DOTS_Sampled_AlphaRemapMax2                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMax2);
    unity_DOTS_Sampled_AlphaRemapMax3                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMax3);

    // Metallic
    unity_DOTS_Sampled_Metallic                           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Metallic);
    unity_DOTS_Sampled_Metallic1                          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Metallic1);
    unity_DOTS_Sampled_Metallic2                          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Metallic2);
    unity_DOTS_Sampled_Metallic3                          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Metallic3);
    unity_DOTS_Sampled_MetallicRemapMin                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _MetallicRemapMin);
    unity_DOTS_Sampled_MetallicRemapMin1                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _MetallicRemapMin1);
    unity_DOTS_Sampled_MetallicRemapMin2                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _MetallicRemapMin2);
    unity_DOTS_Sampled_MetallicRemapMin3                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _MetallicRemapMin3);
    unity_DOTS_Sampled_MetallicRemapMax                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _MetallicRemapMax);
    unity_DOTS_Sampled_MetallicRemapMax1                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _MetallicRemapMax1);
    unity_DOTS_Sampled_MetallicRemapMax2                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _MetallicRemapMax2);
    unity_DOTS_Sampled_MetallicRemapMax3                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _MetallicRemapMax3);

    // Smoothness
    unity_DOTS_Sampled_Smoothness                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Smoothness);
    unity_DOTS_Sampled_Smoothness1                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Smoothness1);
    unity_DOTS_Sampled_Smoothness2                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Smoothness2);
    unity_DOTS_Sampled_Smoothness3                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Smoothness3);
    unity_DOTS_Sampled_SmoothnessRemapMin                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SmoothnessRemapMin);
    unity_DOTS_Sampled_SmoothnessRemapMin1                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SmoothnessRemapMin1);
    unity_DOTS_Sampled_SmoothnessRemapMin2                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SmoothnessRemapMin2);
    unity_DOTS_Sampled_SmoothnessRemapMin3                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SmoothnessRemapMin3);
    unity_DOTS_Sampled_SmoothnessRemapMax                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SmoothnessRemapMax);
    unity_DOTS_Sampled_SmoothnessRemapMax1                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SmoothnessRemapMax1);
    unity_DOTS_Sampled_SmoothnessRemapMax2                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SmoothnessRemapMax2);
    unity_DOTS_Sampled_SmoothnessRemapMax3                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SmoothnessRemapMax3);

    // AO
    unity_DOTS_Sampled_AORemapMin                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AORemapMin);
    unity_DOTS_Sampled_AORemapMin1                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AORemapMin1);
    unity_DOTS_Sampled_AORemapMin2                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AORemapMin2);
    unity_DOTS_Sampled_AORemapMin3                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AORemapMin3);
    unity_DOTS_Sampled_AORemapMax                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AORemapMax);
    unity_DOTS_Sampled_AORemapMax1                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AORemapMax1);
    unity_DOTS_Sampled_AORemapMax2                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AORemapMax2);
    unity_DOTS_Sampled_AORemapMax3                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AORemapMax3);

    // Normals
    unity_DOTS_Sampled_NormalScale                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _NormalScale);
    unity_DOTS_Sampled_NormalScale1                       = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _NormalScale1);
    unity_DOTS_Sampled_NormalScale2                       = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _NormalScale2);
    unity_DOTS_Sampled_NormalScale3                       = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _NormalScale3);
    unity_DOTS_Sampled_InheritBaseNormal1                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InheritBaseNormal1);
    unity_DOTS_Sampled_InheritBaseNormal2                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InheritBaseNormal2);
    unity_DOTS_Sampled_InheritBaseNormal3                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InheritBaseNormal3);

    // Height
    unity_DOTS_Sampled_HeightAmplitude                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightAmplitude);
    unity_DOTS_Sampled_HeightAmplitude1                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightAmplitude1);
    unity_DOTS_Sampled_HeightAmplitude2                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightAmplitude2);
    unity_DOTS_Sampled_HeightAmplitude3                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightAmplitude3);
    unity_DOTS_Sampled_HeightCenter                       = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightCenter);
    unity_DOTS_Sampled_HeightCenter1                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightCenter1);
    unity_DOTS_Sampled_HeightCenter2                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightCenter2);
    unity_DOTS_Sampled_HeightCenter3                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightCenter3);
    unity_DOTS_Sampled_HeightPoMAmplitude                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightPoMAmplitude);
    unity_DOTS_Sampled_HeightPoMAmplitude1                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightPoMAmplitude1);
    unity_DOTS_Sampled_HeightPoMAmplitude2                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightPoMAmplitude2);
    unity_DOTS_Sampled_HeightPoMAmplitude3                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _HeightPoMAmplitude3);
    unity_DOTS_Sampled_InheritBaseHeight1                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InheritBaseHeight1);
    unity_DOTS_Sampled_InheritBaseHeight2                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InheritBaseHeight2);
    unity_DOTS_Sampled_InheritBaseHeight3                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _InheritBaseHeight3);

    // Detail Maps
    unity_DOTS_Sampled_DetailMap_ST                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _DetailMap_ST);
    unity_DOTS_Sampled_DetailMap1_ST                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _DetailMap1_ST);
    unity_DOTS_Sampled_DetailMap2_ST                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _DetailMap2_ST);
    unity_DOTS_Sampled_DetailMap3_ST                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _DetailMap3_ST);
    unity_DOTS_Sampled_DetailAlbedoScale            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailAlbedoScale);
    unity_DOTS_Sampled_DetailAlbedoScale1           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailAlbedoScale1);
    unity_DOTS_Sampled_DetailAlbedoScale2           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailAlbedoScale2);
    unity_DOTS_Sampled_DetailAlbedoScale3           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailAlbedoScale3);
    unity_DOTS_Sampled_DetailNormalScale            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailNormalScale);
    unity_DOTS_Sampled_DetailNormalScale1           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailNormalScale1);
    unity_DOTS_Sampled_DetailNormalScale2           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailNormalScale2);
    unity_DOTS_Sampled_DetailNormalScale3           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailNormalScale3);
    unity_DOTS_Sampled_DetailSmoothnessScale        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailSmoothnessScale);
    unity_DOTS_Sampled_DetailSmoothnessScale1       = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailSmoothnessScale1);
    unity_DOTS_Sampled_DetailSmoothnessScale2       = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailSmoothnessScale2);
    unity_DOTS_Sampled_DetailSmoothnessScale3       = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _DetailSmoothnessScale3);

    // Puddles and Rain
    unity_DOTS_Sampled_PuddlesFramesSize            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _PuddlesFramesSize);
    unity_DOTS_Sampled_PuddlesNormalScale           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _PuddlesNormalScale);
    unity_DOTS_Sampled_PuddlesSize                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _PuddlesSize);
    unity_DOTS_Sampled_PuddlesAnimationSpeed        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _PuddlesAnimationSpeed);
    unity_DOTS_Sampled_RainNormalScale              = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _RainNormalScale);
    unity_DOTS_Sampled_RainSize                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _RainSize);
    unity_DOTS_Sampled_RainAnimationSpeed           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _RainAnimationSpeed);
    unity_DOTS_Sampled_RainDistortionScale          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _RainDistortionScale);
    unity_DOTS_Sampled_RainDistortionSize           = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _RainDistortionSize);
    unity_DOTS_Sampled_RainWetnessFactor            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _RainWetnessFactor);

    // Snow
    unity_DOTS_Sampled_SnowRemap                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _SnowRemap);
    unity_DOTS_Sampled_SnowCoverage                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _SnowCoverage);
    unity_DOTS_Sampled_SnowSharpness                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _SnowSharpness);
    unity_DOTS_Sampled_SnowSize                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _SnowSize);
    unity_DOTS_Sampled_SnowHeightAmplitude          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _SnowHeightAmplitude);
    unity_DOTS_Sampled_SnowHeightCenter             = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _SnowHeightCenter);
    unity_DOTS_Sampled_SnowHeightMapSize            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _SnowHeightMapSize);

    // Emission
    unity_DOTS_Sampled_EmissionMap_ST               = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _EmissionMap_ST);
    unity_DOTS_Sampled_EmissionColor                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4, _EmissionColor);
    unity_DOTS_Sampled_EmissionScale                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _EmissionScale);
    unity_DOTS_Sampled_EmissionFresnelPower         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _EmissionFresnelPower);

    // Advanced Options
    unity_DOTS_Sampled_HorizonFade                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _HorizonFade);
    unity_DOTS_Sampled_GIOcclusionBias              = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float , _GIOcclusionBias);

    unity_DOTS_Sampled_ComputeMeshIndex                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _ComputeMeshIndex);
}

#undef UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES
#define UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES() SetupDOTSLayeredLitMaterialPropertyCaches()

// Surface Options
#define _Surface                            unity_DOTS_Sampled_Surface
#define _DoubleSidedConstants               unity_DOTS_Sampled_DoubleSidedConstants
#define _AlphaCutoff                        unity_DOTS_Sampled_AlphaCutoff
#define _AlphaCutoffShadow                  unity_DOTS_Sampled_AlphaCutoffShadow
#define _SpecularAAScreenSpaceVariance      unity_DOTS_Sampled_SpecularAAScreenSpaceVariance
#define _SpecularAAThreshold                unity_DOTS_Sampled_SpecularAAThreshold

// PPD
#define _PPDMinSamples                      unity_DOTS_Sampled_PPDMinSamples
#define _PPDMaxSamples                      unity_DOTS_Sampled_PPDMaxSamples
#define _PPDLodThreshold                    unity_DOTS_Sampled_PPDLodThreshold
#define _InvPrimScale                       unity_DOTS_Sampled_InvPrimScale
#define _InvTilingScale                     unity_DOTS_Sampled_InvTilingScale
#define _InvTilingScale1                    unity_DOTS_Sampled_InvTilingScale1
#define _InvTilingScale2                    unity_DOTS_Sampled_InvTilingScale2
#define _InvTilingScale3                    unity_DOTS_Sampled_InvTilingScale3

// Tessellation
#define _TessellationFactor                 unity_DOTS_Sampled_TessellationFactor
#define _TessellationEdgeLength             unity_DOTS_Sampled_TessellationEdgeLength
#define _TessellationFactorMinDistance      unity_DOTS_Sampled_TessellationFactorMinDistance
#define _TessellationFactorMaxDistance      unity_DOTS_Sampled_TessellationFactorMaxDistance
#define _TessellationShapeFactor            unity_DOTS_Sampled_TessellationShapeFactor
#define _TessellationBackFaceCullEpsilon    unity_DOTS_Sampled_TessellationBackFaceCullEpsilon

// Surface Inputs
#define _LayerMaskMap_ST                    unity_DOTS_Sampled_LayerMaskMap_ST
#define _HeightTransition                   unity_DOTS_Sampled_HeightTransition
#define _LayerCount                         unity_DOTS_Sampled_LayerCount
#define _OpacityAsDensity                   unity_DOTS_Sampled_OpacityAsDensity
#define _OpacityAsDensity1                  unity_DOTS_Sampled_OpacityAsDensity1
#define _OpacityAsDensity2                  unity_DOTS_Sampled_OpacityAsDensity2
#define _OpacityAsDensity3                  unity_DOTS_Sampled_OpacityAsDensity3

// Base Maps
#define _BaseMap_ST                         unity_DOTS_Sampled_BaseMap_ST
#define _BaseMap1_ST                        unity_DOTS_Sampled_BaseMap1_ST
#define _BaseMap2_ST                        unity_DOTS_Sampled_BaseMap2_ST
#define _BaseMap3_ST                        unity_DOTS_Sampled_BaseMap3_ST
#define _BaseColor                          unity_DOTS_Sampled_BaseColor
#define _BaseColor1                         unity_DOTS_Sampled_BaseColor1
#define _BaseColor2                         unity_DOTS_Sampled_BaseColor2
#define _BaseColor3                         unity_DOTS_Sampled_BaseColor3
#define _InheritBaseColor1                  unity_DOTS_Sampled_InheritBaseColor1
#define _InheritBaseColor2                  unity_DOTS_Sampled_InheritBaseColor2
#define _InheritBaseColor3                  unity_DOTS_Sampled_InheritBaseColor3

// Alpha
#define _AlphaRemapMin                      unity_DOTS_Sampled_AlphaRemapMin
#define _AlphaRemapMin1                     unity_DOTS_Sampled_AlphaRemapMin1
#define _AlphaRemapMin2                     unity_DOTS_Sampled_AlphaRemapMin2
#define _AlphaRemapMin3                     unity_DOTS_Sampled_AlphaRemapMin3
#define _AlphaRemapMax                      unity_DOTS_Sampled_AlphaRemapMax
#define _AlphaRemapMax1                     unity_DOTS_Sampled_AlphaRemapMax1
#define _AlphaRemapMax2                     unity_DOTS_Sampled_AlphaRemapMax2
#define _AlphaRemapMax3                     unity_DOTS_Sampled_AlphaRemapMax3

// Metallic
#define _Metallic                           unity_DOTS_Sampled_Metallic
#define _Metallic1                          unity_DOTS_Sampled_Metallic1
#define _Metallic2                          unity_DOTS_Sampled_Metallic2
#define _Metallic3                          unity_DOTS_Sampled_Metallic3
#define _MetallicRemapMin                   unity_DOTS_Sampled_MetallicRemapMin
#define _MetallicRemapMin1                  unity_DOTS_Sampled_MetallicRemapMin1
#define _MetallicRemapMin2                  unity_DOTS_Sampled_MetallicRemapMin2
#define _MetallicRemapMin3                  unity_DOTS_Sampled_MetallicRemapMin3
#define _MetallicRemapMax                   unity_DOTS_Sampled_MetallicRemapMax
#define _MetallicRemapMax1                  unity_DOTS_Sampled_MetallicRemapMax1
#define _MetallicRemapMax2                  unity_DOTS_Sampled_MetallicRemapMax2
#define _MetallicRemapMax3                  unity_DOTS_Sampled_MetallicRemapMax3

// Smoothness
#define _Smoothness                         unity_DOTS_Sampled_Smoothness
#define _Smoothness1                        unity_DOTS_Sampled_Smoothness1
#define _Smoothness2                        unity_DOTS_Sampled_Smoothness2
#define _Smoothness3                        unity_DOTS_Sampled_Smoothness3
#define _SmoothnessRemapMin                 unity_DOTS_Sampled_SmoothnessRemapMin
#define _SmoothnessRemapMin1                unity_DOTS_Sampled_SmoothnessRemapMin1
#define _SmoothnessRemapMin2                unity_DOTS_Sampled_SmoothnessRemapMin2
#define _SmoothnessRemapMin3                unity_DOTS_Sampled_SmoothnessRemapMin3
#define _SmoothnessRemapMax                 unity_DOTS_Sampled_SmoothnessRemapMax
#define _SmoothnessRemapMax1                unity_DOTS_Sampled_SmoothnessRemapMax1
#define _SmoothnessRemapMax2                unity_DOTS_Sampled_SmoothnessRemapMax2
#define _SmoothnessRemapMax3                unity_DOTS_Sampled_SmoothnessRemapMax3

// AO
#define _AORemapMin                         unity_DOTS_Sampled_AORemapMin
#define _AORemapMin1                        unity_DOTS_Sampled_AORemapMin1
#define _AORemapMin2                        unity_DOTS_Sampled_AORemapMin2
#define _AORemapMin3                        unity_DOTS_Sampled_AORemapMin3
#define _AORemapMax                         unity_DOTS_Sampled_AORemapMax
#define _AORemapMax1                        unity_DOTS_Sampled_AORemapMax1
#define _AORemapMax2                        unity_DOTS_Sampled_AORemapMax2
#define _AORemapMax3                        unity_DOTS_Sampled_AORemapMax3

// Normals
#define _NormalScale                        unity_DOTS_Sampled_NormalScale
#define _NormalScale1                       unity_DOTS_Sampled_NormalScale1
#define _NormalScale2                       unity_DOTS_Sampled_NormalScale2
#define _NormalScale3                       unity_DOTS_Sampled_NormalScale3
#define _InheritBaseNormal1                 unity_DOTS_Sampled_InheritBaseNormal1
#define _InheritBaseNormal2                 unity_DOTS_Sampled_InheritBaseNormal2
#define _InheritBaseNormal3                 unity_DOTS_Sampled_InheritBaseNormal3

// Height
#define _HeightAmplitude                    unity_DOTS_Sampled_HeightAmplitude
#define _HeightAmplitude1                   unity_DOTS_Sampled_HeightAmplitude1
#define _HeightAmplitude2                   unity_DOTS_Sampled_HeightAmplitude2
#define _HeightAmplitude3                   unity_DOTS_Sampled_HeightAmplitude3
#define _HeightCenter                       unity_DOTS_Sampled_HeightCenter
#define _HeightCenter1                      unity_DOTS_Sampled_HeightCenter1
#define _HeightCenter2                      unity_DOTS_Sampled_HeightCenter2
#define _HeightCenter3                      unity_DOTS_Sampled_HeightCenter3
#define _HeightPoMAmplitude                 unity_DOTS_Sampled_HeightPoMAmplitude
#define _HeightPoMAmplitude1                unity_DOTS_Sampled_HeightPoMAmplitude1
#define _HeightPoMAmplitude2                unity_DOTS_Sampled_HeightPoMAmplitude2
#define _HeightPoMAmplitude3                unity_DOTS_Sampled_HeightPoMAmplitude3
#define _InheritBaseHeight1                 unity_DOTS_Sampled_InheritBaseHeight1
#define _InheritBaseHeight2                 unity_DOTS_Sampled_InheritBaseHeight2
#define _InheritBaseHeight3                 unity_DOTS_Sampled_InheritBaseHeight3

// Detail Maps
#define _DetailMap_ST                       unity_DOTS_Sampled_DetailMap_ST
#define _DetailMap1_ST                      unity_DOTS_Sampled_DetailMap1_ST
#define _DetailMap2_ST                      unity_DOTS_Sampled_DetailMap2_ST
#define _DetailMap3_ST                      unity_DOTS_Sampled_DetailMap3_ST
#define _DetailAlbedoScale                  unity_DOTS_Sampled_DetailAlbedoScale
#define _DetailAlbedoScale1                 unity_DOTS_Sampled_DetailAlbedoScale1
#define _DetailAlbedoScale2                 unity_DOTS_Sampled_DetailAlbedoScale2
#define _DetailAlbedoScale3                 unity_DOTS_Sampled_DetailAlbedoScale3
#define _DetailNormalScale                  unity_DOTS_Sampled_DetailNormalScale
#define _DetailNormalScale1                 unity_DOTS_Sampled_DetailNormalScale1
#define _DetailNormalScale2                 unity_DOTS_Sampled_DetailNormalScale2
#define _DetailNormalScale3                 unity_DOTS_Sampled_DetailNormalScale3
#define _DetailSmoothnessScale              unity_DOTS_Sampled_DetailSmoothnessScale
#define _DetailSmoothnessScale1             unity_DOTS_Sampled_DetailSmoothnessScale1
#define _DetailSmoothnessScale2             unity_DOTS_Sampled_DetailSmoothnessScale2
#define _DetailSmoothnessScale3             unity_DOTS_Sampled_DetailSmoothnessScale3

// Puddles and Rain
#define _PuddlesFramesSize                   unity_DOTS_Sampled_PuddlesFramesSize
#define _PuddlesNormalScale                  unity_DOTS_Sampled_PuddlesNormalScale
#define _PuddlesSize                         unity_DOTS_Sampled_PuddlesSize
#define _PuddlesAnimationSpeed               unity_DOTS_Sampled_PuddlesAnimationSpeed
#define _RainNormalScale                     unity_DOTS_Sampled_RainNormalScale
#define _RainSize                            unity_DOTS_Sampled_RainSize
#define _RainAnimationSpeed                  unity_DOTS_Sampled_RainAnimationSpeed
#define _RainDistortionScale                 unity_DOTS_Sampled_RainDistortionScale
#define _RainDistortionSize                  unity_DOTS_Sampled_RainDistortionSize
#define _RainWetnessFactor                   unity_DOTS_Sampled_RainWetnessFactor

// Snow
#define _SnowRemap                           unity_DOTS_Sampled_SnowRemap
#define _SnowCoverage                        unity_DOTS_Sampled_SnowCoverage
#define _SnowSharpness                       unity_DOTS_Sampled_SnowSharpness
#define _SnowSize                            unity_DOTS_Sampled_SnowSize
#define _SnowHeightAmplitude                 unity_DOTS_Sampled_SnowHeightAmplitude
#define _SnowHeightCenter                    unity_DOTS_Sampled_SnowHeightCenter
#define _SnowHeightMapSize                   unity_DOTS_Sampled_SnowHeightMapSize

// Emission
#define _EmissionMap_ST                      unity_DOTS_Sampled_EmissionMap_ST
#define _EmissionColor                       unity_DOTS_Sampled_EmissionColor
#define _EmissionScale                       unity_DOTS_Sampled_EmissionScale
#define _EmissionFresnelPower                unity_DOTS_Sampled_EmissionFresnelPower

// Advanced Options
#define _HorizonFade                         unity_DOTS_Sampled_HorizonFade
#define _GIOcclusionBias                     unity_DOTS_Sampled_GIOcclusionBias

#define _ComputeMeshIndex                    unity_DOTS_Sampled_ComputeMeshIndex

#endif