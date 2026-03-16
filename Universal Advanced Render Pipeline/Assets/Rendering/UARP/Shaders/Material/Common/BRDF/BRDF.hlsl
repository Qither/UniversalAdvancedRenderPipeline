#ifndef URPPLUS_BRDF_INCLUDED
#define URPPLUS_BRDF_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Deprecated.hlsl"

// Standard dielectric reflectivity coefficient at incident angle (= 4%)
#define kDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04) 

struct BRDFData
{
    half3 albedo;
    half3 diffuse;
    half3 specular;
    half reflectivity;
    half perceptualRoughness;
    half roughness;
    half roughness2;
    half grazingTerm;

    half normalizationTerm; // roughness * 4.0 + 2.0
    half roughness2MinusOne; // roughness^2 - 1.0
};

inline half ReflectivitySpecular(half3 specular)
{
    return Max3(specular.r, specular.g, specular.b);
}

inline half OneMinusReflectivityMetallic(half metallic)
{
    return kDielectricSpec.a - metallic * kDielectricSpec.a;
}

inline half MetallicFromReflectivity(half reflectivity)
{
    return (reflectivity - kDielectricSpec.r) / kDielectricSpec.a;
}

inline void InitializeBRDFDataDirect(half3 albedo, half3 diffuse, half3 specular, half reflectivity, half smoothness,
    half alpha, out BRDFData outBRDFData)
{
    outBRDFData.albedo = albedo;
    outBRDFData.diffuse = diffuse;
    outBRDFData.specular = specular;
    outBRDFData.reflectivity = reflectivity;

    outBRDFData.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(smoothness);
    outBRDFData.roughness = max(PerceptualRoughnessToRoughness(outBRDFData.perceptualRoughness), HALF_MIN_SQRT);
    outBRDFData.roughness2 = max(outBRDFData.roughness * outBRDFData.roughness, HALF_MIN);
    outBRDFData.grazingTerm = saturate(smoothness + reflectivity);
    outBRDFData.normalizationTerm = outBRDFData.roughness * 4.0h + 2.0h;
    outBRDFData.roughness2MinusOne = outBRDFData.roughness2 - 1.0h;

    #if defined(_ALPHAPREMULTIPLY_ON)
        outBRDFData.diffuse *= alpha;
    #endif
}

inline void InitializeBRDFDataDirect(InputData inputData, SurfaceData surfaceData, half3 diffuse, half3 specular,
    half reflectivity, out BRDFData outBRDFData)
{
    InitializeBRDFDataDirect(surfaceData.albedo, diffuse, specular, reflectivity, surfaceData.smoothness,
        surfaceData.alpha, outBRDFData);

    #if defined(_MATERIAL_FEATURE_IRIDESCENCE)
    outBRDFData.specular = IridescenceSpecular(inputData.normalWS, inputData.viewDirectionWS, outBRDFData.specular,
        surfaceData.iridescenceTMS, surfaceData.clearCoatMask);
    #endif
}

inline void InitializeBRDFData(half3 albedo, half metallic, half3 specular, half smoothness, half alpha, out BRDFData outBRDFData)
{
    #ifdef _SPECULAR_SETUP
    half reflectivity = ReflectivitySpecular(specular);
    half3 brdfDiffuse = albedo * (1.0h - reflectivity);
    InitializeBRDFDataDirect(albedo, brdfDiffuse, specular, reflectivity, smoothness, alpha, outBRDFData);
    #else
    half oneMinusReflectivity = OneMinusReflectivityMetallic(metallic);
    half3 brdfDiffuse = albedo * oneMinusReflectivity;
    half3 brdfSpecular = lerp(kDielectricSpec.rgb, albedo, metallic);
    InitializeBRDFDataDirect(albedo, brdfDiffuse, brdfSpecular, 1.0h - oneMinusReflectivity, smoothness, alpha, outBRDFData);
    #endif
}

inline void InitializeBRDFData(InputData inputData, SurfaceData surfaceData, out BRDFData outBRDFData)
{
    #ifdef _SPECULAR_SETUP
    half reflectivity = ReflectivitySpecular(surfaceData.specular);
    half3 brdfDiffuse = surfaceData.albedo * (1.0h - reflectivity);
    InitializeBRDFDataDirect(inputData, surfaceData, brdfDiffuse, surfaceData.specular, reflectivity, outBRDFData);
    #else
    half oneMinusReflectivity = OneMinusReflectivityMetallic(surfaceData.metallic);
    half3 brdfDiffuse = surfaceData.albedo * oneMinusReflectivity;
    half3 brdfSpecular = lerp(kDielectricSpec.rgb, surfaceData.albedo, surfaceData.metallic);
    InitializeBRDFDataDirect(inputData, surfaceData, brdfDiffuse, brdfSpecular, 1.0h - oneMinusReflectivity, outBRDFData);
    #endif
}

inline void InitializeSpecularBRDFData(InputData inputData, SurfaceData surfaceData, out BRDFData outBRDFData)
{
    InitializeBRDFDataDirect(inputData, surfaceData, surfaceData.albedo *
        (1.0h - ReflectivitySpecular(surfaceData.specular)), surfaceData.specular,
        ReflectivitySpecular(surfaceData.specular), outBRDFData);
}

inline void InitializeBRDFDataDirectSheen(half3 albedo, half3 diffuse, half3 specular, half smoothness, half alpha,
    out BRDFData outBRDFData)
{
    InitializeBRDFDataDirect(albedo, diffuse, specular, 1.0h, lerp(0.0h, 0.5h, smoothness), alpha,
        outBRDFData);
}

inline void InitializeFabricBRDFData(SurfaceData surfaceData, out BRDFData outBRDFData)
{
    #if defined (_MATERIAL_FEATURE_SHEEN)
    InitializeBRDFDataDirectSheen(surfaceData.albedo, surfaceData.albedo, surfaceData.specular, surfaceData.smoothness,
        surfaceData.alpha, outBRDFData);
    #else
    InitializeBRDFDataDirect(surfaceData.albedo, surfaceData.albedo *
        (1.0h - ReflectivitySpecular(surfaceData.specular)), surfaceData.specular,
        ReflectivitySpecular(surfaceData.specular), surfaceData.smoothness, surfaceData.alpha, outBRDFData);
    #endif
}

#endif