#ifndef URPPLUS_GEOMETRIC_AA_INCLUDED
#define URPPLUS_GEOMETRIC_AA_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"

void GeometricAAFiltering(float3 geometricNormalWS, inout half perceptualSmoothness)
{
    half variance = GeometricNormalVariance(geometricNormalWS, _SpecularAAScreenSpaceVariance);
    perceptualSmoothness = NormalFiltering(perceptualSmoothness, variance, _SpecularAAThreshold);
}

void GeometricAAFiltering(float3 geometricNormalWS, inout half perceptualSmoothness, inout half coatPerceptualSmoothness)
{
    half variance = GeometricNormalVariance(geometricNormalWS, _SpecularAAScreenSpaceVariance);
    perceptualSmoothness = NormalFiltering(perceptualSmoothness, variance, _SpecularAAThreshold);
}

#endif