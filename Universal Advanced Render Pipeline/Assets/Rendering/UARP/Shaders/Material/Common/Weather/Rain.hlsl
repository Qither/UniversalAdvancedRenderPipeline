#ifndef URPPLUS_RAIN_INCLUDED
#define URPPLUS_RAIN_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/UV/TriplanarMapping.hlsl"

uniform half4 _WetnessColor;
uniform half _RainMultiplier;
uniform half _Wetness;

real2 FlipbookAnimation(real2 uv, uint2 tilesSize, half speed) 
{
    real tileCountX = 1.0 / tilesSize.x;
    real tileCountY = 1.0 / tilesSize.y;

    uint frameIndex = _Time.y * speed % (tilesSize.x * tilesSize.y);

    uint indexX = frameIndex % tilesSize.x;
    uint indexY = tilesSize.y - 1 - (frameIndex / tilesSize.x);

    real2 offset = real2(tileCountX * indexX, tileCountY * indexY);

    return uv * real2(tileCountX, tileCountY) + offset;
}

real2 CalculateRainDistortion(real2 uv)
{
    real2 rainDistortionUV = uv * _RainDistortionSize;

    return SAMPLE_TEXTURE2D(_RainDistortionMap, sampler_LinearRepeat, rainDistortionUV).rg * _RainDistortionScale;
}

half3 ApplyTriplanarRain(UVMapping uvMapping, real2 rainDistortion, half3 puddlesNormal)
{
    real rainTime = frac(_Time.y * _RainAnimationSpeed);
    real2 rainSpeed = real2(0.0, rainTime);

    real2 rainNormalUV_A = (uvMapping.uvXY + rainDistortion + rainSpeed) * _RainSize;
    real2 rainNormalUV_B = (uvMapping.uvZY + rainDistortion + rainSpeed) * _RainSize;

    half rainIntensity_A  = _RainNormalScale * uvMapping.triplanarWeights.z;
    half rainIntensity_B = _RainNormalScale * uvMapping.triplanarWeights.x;

    half3 rainNormal_A = SampleNormal(rainNormalUV_A, TEXTURE2D_ARGS(_RainNormal, sampler_LinearRepeat), rainIntensity_A);
    half3 rainNormal_B = SampleNormal(rainNormalUV_B, TEXTURE2D_ARGS(_RainNormal, sampler_LinearRepeat), rainIntensity_B);

    // Final result
    return BlendNormal(puddlesNormal, BlendNormal(rainNormal_A, rainNormal_B));
}

void ApplyRain(UVMapping uvMapping, half weatherMask, inout SurfaceData surfaceData)
{
    half rainMaskMultiplied = weatherMask * _RainMultiplier;
    half wetnessFactor = _Wetness * _RainWetnessFactor * weatherMask;
    
    if(rainMaskMultiplied > 0 || wetnessFactor > 0)
    {
        // Perform puddles animation
        real2 puddlesUV = FlipbookAnimation(frac(uvMapping.uvXZ * _PuddlesSize), _PuddlesFramesSize.xy, _PuddlesAnimationSpeed);
        half3 puddlesNormalTS = SampleNormal(puddlesUV, TEXTURE2D_ARGS(_PuddlesNormal, sampler_LinearRepeat), _PuddlesNormalScale * saturate(uvMapping.normalWS.y));
    
        half3 rainNormalTS = puddlesNormalTS;
        #ifdef _RAIN_TRIPLANAR
        real2 rainDistortion = CalculateRainDistortion(uvMapping.uv);
        rainNormalTS = ApplyTriplanarRain(uvMapping, rainDistortion, puddlesNormalTS);
        #endif

        surfaceData.albedo = lerp(surfaceData.albedo, _WetnessColor.rgb, wetnessFactor * _WetnessColor.a);
        surfaceData.normalTS = lerp(surfaceData.normalTS, BlendNormalRNM(rainNormalTS, surfaceData.normalTS), rainMaskMultiplied);
    }

    surfaceData.smoothness = lerp(surfaceData.smoothness, 1.0h, wetnessFactor);
}

#endif