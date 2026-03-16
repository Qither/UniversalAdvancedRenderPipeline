#ifndef URPPLUS_SNOW_INCLUDED
#define URPPLUS_SNOW_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/UV/TriplanarMapping.hlsl"

uniform half4 _SnowGlobalColor;
uniform half4 _SnowGlobalCoverage;

half GetSnowTopMask(real3 normalWS)
{
    real3 snowCoverageWS = normalWS * _SnowCoverage.xyz * _SnowGlobalCoverage.xyz;
    half snowCoverage = dot(snowCoverageWS, 1.0);
    half snowCoverageOffset = clamp(snowCoverage + _SnowCoverage.w, 0.0h, 1.0h);
    return smoothstep(0.0h, 1.0h - _SnowSharpness, snowCoverageOffset);
}

half GetSnowVerticalMask(real3 positionOS)
{
    return saturate((_SnowRemap.y - positionOS.y) / (_SnowRemap.y - _SnowRemap.x));
}

half GetSnowMask(real3 positionOS, real3 normalWS)
{
    half snowMask = GetSnowTopMask(normalWS);

    #ifdef _SNOW_VERTICAL_MASK
        snowMask *= GetSnowVerticalMask(positionOS);
    #endif

    return snowMask;
}

void ApplySnow(UVMapping uvMapping, real3 positionOS, half weatherMask, inout SurfaceData surfaceData)
{
    half snowMask = GetSnowMask(positionOS, uvMapping.normalWS) * _SnowGlobalColor.a * weatherMask;

    half2 snowUVScale = _SnowSize;
    uvMapping.uvXY *= snowUVScale;
    uvMapping.uvXZ *= snowUVScale;
    uvMapping.uvZY *= snowUVScale;
    
    half3 snowAlbedo = SAMPLE_TEXTURE_TRIPLANAR_RGB(_SnowAlbedoMap, sampler_LinearRepeat, uvMapping) * _SnowGlobalColor.rgb;
    surfaceData.albedo = lerp(surfaceData.albedo, snowAlbedo, snowMask);
    surfaceData.alpha = lerp(surfaceData.alpha, 1.0h, snowMask);

    #ifdef _SNOW_DETAIL
    half3 snowDetail = SAMPLE_TEXTURE_TRIPLANAR_RGB(_SnowDetailMap, sampler_LinearRepeat, uvMapping);
    half3 snowNormalTS = normalize(UnpackNormalAG(half4(1.0h, snowDetail.r, 1.0h, snowDetail.g), _SnowRemap.z));
    half snowSmoothness = saturate(snowDetail.b * _SnowRemap.w);
    surfaceData.normalTS = lerp(surfaceData.normalTS, snowNormalTS, snowMask);
    surfaceData.smoothness = lerp(surfaceData.smoothness, snowSmoothness, snowMask);
    #endif

    #if defined(_SPECULAR_SETUP) || defined(FOR_SPECULAR_MODE_SNOW)
    surfaceData.specular = lerp(surfaceData.specular, half3(0.2, 0.2, 0.2), snowMask);
    #else
    surfaceData.metallic = lerp(surfaceData.metallic, 0.0h, snowMask);
    #endif

    #ifdef _MATERIAL_FEATURE_IRIDESCENCE
    surfaceData.iridescenceTMS.y = lerp(surfaceData.iridescenceTMS.y, 0.0h, snowMask);
    #endif
}

half ComputePerVertexSnowHeightMap(UVMapping uvMapping, real3 positionOS)
{
    half weatherMask = SAMPLE_TEXTURE2D_LOD(_WeatherMaskMap, sampler_LinearRepeat, uvMapping.uv, 1.0h).g;
    half snowMask = GetSnowMask(positionOS, uvMapping.normalWS) * _SnowGlobalColor.a * weatherMask;

    uvMapping.uvXY *= _SnowHeightMapSize;
    uvMapping.uvXZ *= _SnowHeightMapSize;
    uvMapping.uvZY *= _SnowHeightMapSize;

    #ifdef _SNOW_HEIGHTMAP
        half height = (SAMPLE_TEXTURE_TRIPLANAR_R_LOD(_SnowHeightMap, sampler_LinearRepeat, uvMapping, 1.0h).r - _SnowHeightCenter) * _SnowHeightAmplitude;
        #if defined(LOD_FADE_CROSSFADE) && defined(_TESSELLATION_DISPLACEMENT)
            height *= unity_LODFade.x;
        #endif
    #else
        half height = 0.0;
    #endif

    return height * snowMask;
}

#endif