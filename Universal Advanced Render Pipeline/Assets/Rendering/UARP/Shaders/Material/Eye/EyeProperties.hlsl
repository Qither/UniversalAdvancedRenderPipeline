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

half _ScleraSmoothness;
half _CorneaSmoothness;
half _ScleraNormalScale;
half _IrisNormalScale;

half4 _IrisClampColor;
half _PupilRadius;
half _PupilAperture;
half _MinimalPupilAperture;
half _MaximalPupilAperture;
half _IrisOffset;

half _LimbalRingSizeIris;
half _LimbalRingSizeSclera;
half _LimbalRingFade;
half _LimbalRingIntensity;

half4 _EmissionColor;
half _EmissionScale;

half _MeshScale;
half4 _PositionOffset;

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

    UNITY_DOTS_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float , _AlphaRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _AlphaRemapMax)

    UNITY_DOTS_INSTANCED_PROP(float , _ScleraSmoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _CorneaSmoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _ScleraNormalScale)
    UNITY_DOTS_INSTANCED_PROP(float , _IrisNormalScale)

    UNITY_DOTS_INSTANCED_PROP(float4, _IrisClampColor)
    UNITY_DOTS_INSTANCED_PROP(float , _PupilRadius)
    UNITY_DOTS_INSTANCED_PROP(float , _PupilAperture)
    UNITY_DOTS_INSTANCED_PROP(float , _MinimalPupilAperture)
    UNITY_DOTS_INSTANCED_PROP(float , _MaximalPupilAperture)
    UNITY_DOTS_INSTANCED_PROP(float , _IrisOffset)

    UNITY_DOTS_INSTANCED_PROP(float , _LimbalRingSizeIris)
    UNITY_DOTS_INSTANCED_PROP(float , _LimbalRingSizeSclera)
    UNITY_DOTS_INSTANCED_PROP(float , _LimbalRingFade)
    UNITY_DOTS_INSTANCED_PROP(float , _LimbalRingIntensity)

    UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float , _EmissionScale)
    
    UNITY_DOTS_INSTANCED_PROP(float, _MeshScale)
    UNITY_DOTS_INSTANCED_PROP(float4, _PositionOffset)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

// Define static variables to cache DOTS instanced properties
static float unity_DOTS_Sampled_Surface;
static float4 unity_DOTS_Sampled_DoubleSidedConstants;
static float unity_DOTS_Sampled_AlphaCutoff;
static float unity_DOTS_Sampled_AlphaCutoffShadow;
static float unity_DOTS_Sampled_SpecularAAScreenSpaceVariance;
static float unity_DOTS_Sampled_SpecularAAThreshold;

static float4 unity_DOTS_Sampled_BaseMap_ST;
static float4 unity_DOTS_Sampled_BaseColor;
static float unity_DOTS_Sampled_AlphaRemapMin;
static float unity_DOTS_Sampled_AlphaRemapMax;

static float unity_DOTS_Sampled_ScleraSmoothness;
static float unity_DOTS_Sampled_CorneaSmoothness;
static float unity_DOTS_Sampled_ScleraNormalScale;
static float unity_DOTS_Sampled_IrisNormalScale;

static float4 unity_DOTS_Sampled_IrisClampColor;
static float unity_DOTS_Sampled_PupilRadius;
static float unity_DOTS_Sampled_PupilAperture;
static float unity_DOTS_Sampled_MinimalPupilAperture;
static float unity_DOTS_Sampled_MaximalPupilAperture;
static float unity_DOTS_Sampled_IrisOffset;          

static float unity_DOTS_Sampled_LimbalRingSizeIris;
static float unity_DOTS_Sampled_LimbalRingSizeSclera;
static float unity_DOTS_Sampled_LimbalRingFade;
static float unity_DOTS_Sampled_LimbalRingIntensity;

static float4 unity_DOTS_Sampled_EmissionColor;
static float unity_DOTS_Sampled_EmissionScale;

static float unity_DOTS_Sampled_MeshScale;
static float4 unity_DOTS_Sampled_PositionOffset;

void SetupDOTSEyeMaterialPropertyCaches()
{
    unity_DOTS_Sampled_Surface                            = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _Surface);
    unity_DOTS_Sampled_DoubleSidedConstants               = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _DoubleSidedConstants);
    unity_DOTS_Sampled_AlphaCutoff                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaCutoff);
    unity_DOTS_Sampled_AlphaCutoffShadow                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaCutoffShadow);
    unity_DOTS_Sampled_SpecularAAScreenSpaceVariance      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SpecularAAScreenSpaceVariance);
    unity_DOTS_Sampled_SpecularAAThreshold                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _SpecularAAThreshold);

    unity_DOTS_Sampled_BaseMap_ST                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseMap_ST);
    unity_DOTS_Sampled_BaseColor                          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _BaseColor);
    unity_DOTS_Sampled_AlphaRemapMin                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMin);
    unity_DOTS_Sampled_AlphaRemapMax                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _AlphaRemapMax);

    unity_DOTS_Sampled_ScleraSmoothness                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _ScleraSmoothness);
    unity_DOTS_Sampled_CorneaSmoothness                   = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _CorneaSmoothness);
    unity_DOTS_Sampled_ScleraNormalScale                  = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _ScleraNormalScale);
    unity_DOTS_Sampled_IrisNormalScale                    = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _IrisNormalScale);

    unity_DOTS_Sampled_IrisClampColor                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _IrisClampColor);
    unity_DOTS_Sampled_PupilRadius                        = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _PupilRadius);
    unity_DOTS_Sampled_PupilAperture                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _PupilAperture);
    unity_DOTS_Sampled_MinimalPupilAperture               = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _MinimalPupilAperture);
    unity_DOTS_Sampled_MaximalPupilAperture               = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _MaximalPupilAperture);
    unity_DOTS_Sampled_IrisOffset                         = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _IrisOffset);

    unity_DOTS_Sampled_LimbalRingSizeIris                 = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _LimbalRingSizeIris);
    unity_DOTS_Sampled_LimbalRingSizeSclera               = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _LimbalRingSizeSclera);
    unity_DOTS_Sampled_LimbalRingFade                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _LimbalRingFade);
    unity_DOTS_Sampled_LimbalRingIntensity                = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _LimbalRingIntensity);

    unity_DOTS_Sampled_EmissionColor                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _EmissionColor);
    unity_DOTS_Sampled_EmissionScale                      = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _EmissionScale);

    unity_DOTS_Sampled_MeshScale                          = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float  , _MeshScale);
    unity_DOTS_Sampled_PositionOffset                     = UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(float4 , _PositionOffset);
}

#undef UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES
#define UNITY_SETUP_DOTS_MATERIAL_PROPERTY_CACHES() SetupDOTSEyeMaterialPropertyCaches()

#define _Surface                            unity_DOTS_Sampled_Surface
#define _DoubleSidedConstants               unity_DOTS_Sampled_DoubleSidedConstants
#define _AlphaCutoff                        unity_DOTS_Sampled_AlphaCutoff
#define _AlphaCutoffShadow                  unity_DOTS_Sampled_AlphaCutoffShadow
#define _SpecularAAThreshold                unity_DOTS_Sampled_SpecularAAScreenSpaceVariance
#define _SpecularAAScreenSpaceVariance      unity_DOTS_Sampled_SpecularAAThreshold

#define _BaseMap_ST                         unity_DOTS_Sampled_BaseMap_ST
#define _BaseColor                          unity_DOTS_Sampled_BaseColor
#define _AlphaRemapMin                      unity_DOTS_Sampled_AlphaRemapMin
#define _AlphaRemapMax                      unity_DOTS_Sampled_AlphaRemapMax

#define _ScleraSmoothness                   unity_DOTS_Sampled_ScleraSmoothness
#define _CorneaSmoothness                   unity_DOTS_Sampled_CorneaSmoothness
#define _ScleraNormalScale                  unity_DOTS_Sampled_ScleraNormalScale
#define _IrisNormalScale                    unity_DOTS_Sampled_IrisNormalScale

#define _IrisClampColor                     unity_DOTS_Sampled_IrisClampColor
#define _PupilRadius                        unity_DOTS_Sampled_PupilRadius
#define _PupilAperture                      unity_DOTS_Sampled_PupilAperture
#define _MinimalPupilAperture               unity_DOTS_Sampled_MinimalPupilAperture
#define _MaximalPupilAperture               unity_DOTS_Sampled_MaximalPupilAperture
#define _IrisOffset                         unity_DOTS_Sampled_IrisOffset

#define _LimbalRingSizeIris                 unity_DOTS_Sampled_LimbalRingSizeIris
#define _LimbalRingSizeSclera               unity_DOTS_Sampled_LimbalRingSizeSclera
#define _LimbalRingFade                     unity_DOTS_Sampled_LimbalRingFade
#define _LimbalRingIntensity                unity_DOTS_Sampled_LimbalRingIntensity

#define _EmissionColor                      unity_DOTS_Sampled_EmissionColor
#define _EmissionScale                      unity_DOTS_Sampled_EmissionScale

#define _MeshScale                          unity_DOTS_Sampled_MeshScale
#define _PositionOffset                     unity_DOTS_Sampled_PositionOffset

#endif