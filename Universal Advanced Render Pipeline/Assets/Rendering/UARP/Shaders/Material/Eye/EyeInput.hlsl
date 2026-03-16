#ifndef URPPLUS_EYE_INPUT_INCLUDED
#define URPPLUS_EYE_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Inputs/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Eye/EyeProperties.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Eye/EyeMaps.hlsl"

#if defined(_SCLERA_NORMALMAP) || defined(_IRIS_NORMALMAP)
    #define _NORMAL
#endif

#if defined(_NORMAL) || defined(_DOUBLESIDED_ON)
    #define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif

half CalculateSurfaceMask(float3 positionOS)
{
    half irisRadius = 0.225h;
    half osRadius = length(positionOS.xy);
    half outerBlendRegionRadius = irisRadius + 0.02;
    half irisFactor = osRadius - irisRadius;
    half blendLerpFactor = 1.0 - irisFactor / (0.04);
    blendLerpFactor = pow(blendLerpFactor, 8.0);
    blendLerpFactor = 1.0 - blendLerpFactor;

    return (osRadius > outerBlendRegionRadius) ? 0.0 : ((osRadius < irisRadius) ? 1.0 : (lerp(1.0, 0.0, blendLerpFactor)));
}

half3 SampleEyeNormal(float2 uv, TEXTURE2D_PARAM(normalMap, sampler_normalMap), half scale = half(1.0))
{
    #ifdef _NORMAL
        half4 normal = SAMPLE_TEXTURE2D(normalMap, sampler_normalMap, uv);
        return ScaleNormal(normal, scale);
    #else
        return half3(0.0h, 0.0h, 1.0h);
    #endif
}

inline void InitializeSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    outSurfaceData = EmptyFill();
}

#endif