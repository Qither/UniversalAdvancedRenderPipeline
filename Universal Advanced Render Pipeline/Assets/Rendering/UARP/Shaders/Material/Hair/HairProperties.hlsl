#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
half _Surface;
half4 _DoubleSidedConstants;
half _AlphaCutoff;
half _AlphaCutoffShadow;
half _SpecularAAScreenSpaceVariance;
half _SpecularAAThreshold;

float4 _BaseMap_ST;
half4 _BaseColor;
half _AlphaRemapMin;
half _AlphaRemapMax;
half _NormalScale;

half _AORemapMin;
half _AORemapMax;

float4 _SmoothnessMaskMap_ST;
half _Smoothness;
half _SmoothnessRemapMin;
half _SmoothnessRemapMax;

half4 _SpecularColor;
half _SpecularMultiplier;
half _SpecularShift;
half _SecondarySpecularMultiplier;
half _SecondarySpecularShift;

half4 _TransmissionColor;
half _TransmissionIntensity;

half4 _StaticLightColor;
half4 _StaticLightVector;

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

    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float , _AlphaRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _AlphaRemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _NormalScale)

    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMax)

    UNITY_DOTS_INSTANCED_PROP(float , _Smoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMax)
    
    UNITY_DOTS_INSTANCED_PROP(float4, _SpecularColor)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularMultiplier)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularShift)
    UNITY_DOTS_INSTANCED_PROP(float , _SecondarySpecularMultiplier)
    UNITY_DOTS_INSTANCED_PROP(float , _SecondarySpecularShift)

    UNITY_DOTS_INSTANCED_PROP(float4, _TransmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float , _TransmissionIntensity)
    
    UNITY_DOTS_INSTANCED_PROP(float4, _StaticLightColor)
    UNITY_DOTS_INSTANCED_PROP(float4, _StaticLightVector)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

// Define static variables to cache DOTS instanced properties
static float unity_DOTS_Sampled_Surface;
static float4 unity_DOTS_Sampled_DoubleSidedConstants;
static float unity_DOTS_Sampled_AlphaCutoff;
static float unity_DOTS_Sampled_AlphaCutoffShadow;
static float unity_DOTS_Sampled_SpecularAAScreenSpaceVariance;
static float unity_DOTS_Sampled_SpecularAAThreshold;

static float4 unity_DOTS_Sampled_BaseColor;
static float unity_DOTS_Sampled_AlphaRemapMin;
static float unity_DOTS_Sampled_AlphaRemapMax;
static float unity_DOTS_Sampled_NormalScale;

static float unity_DOTS_Sampled_AORemapMin;
static float unity_DOTS_Sampled_AORemapMax;

static float unity_DOTS_Sampled_Smoothness;
static float unity_DOTS_Sampled_SmoothnessRemapMin;
static float unity_DOTS_Sampled_SmoothnessRemapMax;

static float4 unity_DOTS_Sampled_SpecularColor;
static float unity_DOTS_Sampled_SpecularMultiplier;
static float unity_DOTS_Sampled_SpecularShift;

static float unity_DOTS_Sampled_SecondarySpecularMultiplier;
static float unity_DOTS_Sampled_SecondarySpecularShift;

static float4 unity_DOTS_Sampled_TransmissionColor;
static float unity_DOTS_Sampled_TransmissionIntensity;

static float4 unity_DOTS_Sampled_StaticLightColor;
static float4 unity_DOTS_Sampled_StaticLightVector;


void SetupDOTSHairMaterialPropertyCaches()
{
    unity_DOTS_Sampled_Surface                            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Surface);
    unity_DOTS_Sampled_DoubleSidedConstants               = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _DoubleSidedConstants);
    unity_DOTS_Sampled_AlphaCutoff                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaCutoff);
    unity_DOTS_Sampled_AlphaCutoffShadow                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaCutoffShadow);
    unity_DOTS_Sampled_SpecularAAScreenSpaceVariance      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SpecularAAScreenSpaceVariance);
    unity_DOTS_Sampled_SpecularAAThreshold                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SpecularAAThreshold);

    unity_DOTS_Sampled_BaseColor                          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseColor);
    unity_DOTS_Sampled_AlphaRemapMin                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMin);
    unity_DOTS_Sampled_AlphaRemapMax                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMax);
    unity_DOTS_Sampled_NormalScale                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _NormalScale);
    
    unity_DOTS_Sampled_AORemapMin                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AORemapMin);
    unity_DOTS_Sampled_AORemapMax                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AORemapMax);

    unity_DOTS_Sampled_Smoothness                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Smoothness);
    unity_DOTS_Sampled_SmoothnessRemapMin                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SmoothnessRemapMin);
    unity_DOTS_Sampled_SmoothnessRemapMax                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SmoothnessRemapMax);

    unity_DOTS_Sampled_SpecularColor                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _SpecularColor);
    unity_DOTS_Sampled_SpecularMultiplier                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SpecularMultiplier);
    unity_DOTS_Sampled_SpecularShift                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SpecularShift);

    unity_DOTS_Sampled_SecondarySpecularMultiplier        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SecondarySpecularMultiplier);
    unity_DOTS_Sampled_SecondarySpecularShift             = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SecondarySpecularShift);

    unity_DOTS_Sampled_TransmissionColor                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _TransmissionColor);
    unity_DOTS_Sampled_TransmissionIntensity              = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _TransmissionIntensity);

    unity_DOTS_Sampled_StaticLightColor                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _StaticLightColor);
    unity_DOTS_Sampled_StaticLightVector                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _StaticLightVector);
}

#undef UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES
#define UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES() SetupDOTSHairMaterialPropertyCaches()

#define _Surface                            unity_DOTS_Sampled_Surface
#define _DoubleSidedConstants               unity_DOTS_Sampled_DoubleSidedConstants
#define _AlphaCutoff                        unity_DOTS_Sampled_AlphaCutoff
#define _AlphaCutoffShadow                  unity_DOTS_Sampled_AlphaCutoffShadow
#define _SpecularAAThreshold                unity_DOTS_Sampled_SpecularAAScreenSpaceVariance
#define _SpecularAAScreenSpaceVariance      unity_DOTS_Sampled_SpecularAAThreshold

#define _BaseColor                          unity_DOTS_Sampled_BaseColor
#define _AlphaRemapMin                      unity_DOTS_Sampled_AlphaRemapMin
#define _AlphaRemapMax                      unity_DOTS_Sampled_AlphaRemapMax
#define _NormalScale                        unity_DOTS_Sampled_NormalScale

#define _AORemapMin                         unity_DOTS_Sampled_AORemapMin
#define _AORemapMax                         unity_DOTS_Sampled_AORemapMax

#define _Smoothness                         unity_DOTS_Sampled_Smoothness
#define _SmoothnessRemapMin                 unity_DOTS_Sampled_SmoothnessRemapMin
#define _SmoothnessRemapMax                 unity_DOTS_Sampled_SmoothnessRemapMax

#define _SpecularColor                      unity_DOTS_Sampled_SpecularColor
#define _SpecularMultiplier                 unity_DOTS_Sampled_SpecularMultiplier
#define _SpecularShift                      unity_DOTS_Sampled_SpecularShift

#define _SecondarySpecularMultiplier        unity_DOTS_Sampled_SecondarySpecularMultiplier
#define _SecondarySpecularShift             unity_DOTS_Sampled_SecondarySpecularShift

#define _TransmissionColor                  unity_DOTS_Sampled_TransmissionColor
#define _TransmissionIntensity              unity_DOTS_Sampled_TransmissionIntensity

#define _StaticLightColor                   unity_DOTS_Sampled_StaticLightColor
#define _StaticLightVector                  unity_DOTS_Sampled_StaticLightVector

#endif