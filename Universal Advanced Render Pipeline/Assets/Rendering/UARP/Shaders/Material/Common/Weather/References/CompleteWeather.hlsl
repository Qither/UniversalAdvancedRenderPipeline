#ifndef URPPLUS_WEATHER_INCLUDED
#define URPPLUS_WEATHER_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/UV/TriplanarMapping.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Weather/Rain.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Weather/Snow.hlsl"

void ApplyWeather(real3 positionWS, real3 normalWS, real2 uv, inout SurfaceData surfaceData)
{
    // Initialize UV data
    real3 positionOS = mul(GetWorldToObjectMatrix(), half4(positionWS, 1.0)).xyz;
    UVMapping uvMapping = InitializeUVData(positionWS, normalWS, uv);

    half2 weatherMask = SAMPLE_TEXTURE2D(_WeatherMaskMap, sampler_LinearRepeat, uvMapping.uv).rg;

    ApplyRain(uvMapping, weatherMask.r, surfaceData);
    ApplySnow(uvMapping, positionOS, weatherMask.g, surfaceData);
}


#endif