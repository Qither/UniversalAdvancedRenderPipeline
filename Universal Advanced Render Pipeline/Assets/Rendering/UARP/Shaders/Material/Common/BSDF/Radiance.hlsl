#ifndef URPPLUS_RADIANCE_INCLUDED
#define URPPLUS_RADIANCE_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/BSDF/SubsurfaceScattering.hlsl"

#define EYEWRAP 0.26179938

void ApplyRefractionLightAttenuation(inout half3 lightAttenuation, half NdotL, half shadowAttenuation, half alpha)
{
    #ifndef _REFRACTION
        lightAttenuation *= shadowAttenuation * NdotL;
    #else
        half attenuation = shadowAttenuation * NdotL;
        half refractedShadowAttenuation = lerp(1.0h, attenuation, _RefractionShadowAttenuation);
        lightAttenuation *= lerp(refractedShadowAttenuation, attenuation, alpha);
    #endif
}

void ApplyRefractionLightAttenuation(inout half3 lightAttenuation, half3 NdotL, half3 shadowAttenuation, half alpha)
{
    #ifndef _REFRACTION
        lightAttenuation *= shadowAttenuation * NdotL;
    #else
        half3 refractedShadowAttenuation = lerp(half3(1.0, 1.0, 1.0), shadowAttenuation, _RefractionShadowAttenuation);
        lightAttenuation *= lerp(refractedShadowAttenuation, shadowAttenuation * NdotL, alpha);
    #endif
}

/******Simple Radiance Function******/
half3 ComputeRadiance(Light light, half3 normalWS, half alpha)
{
    half NdotL = saturate(dot(normalWS, light.direction));
    half3 radiance = light.color * light.distanceAttenuation;
    ApplyRefractionLightAttenuation(radiance, NdotL, light.shadowAttenuation, alpha);

    return radiance;
}

/*****Complex Radiance Function*****/
half3 ComputeComplexRadiance(SurfaceData surfaceData, BRDFData brdfData, VectorsData vData, Light light)
{
    half3 radiance = light.color * light.distanceAttenuation;
    #ifndef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
        half NdotL = saturate(dot(vData.normalWS, light.direction));
    #else
        half3 NdotL = SubSurfaceScattering(surfaceData, brdfData, light, vData.normalWS);

        #if defined(_MATERIAL_FEATURE_TRANSMISSION)
            NdotL += Transmission(light, vData.normalWS, surfaceData.diffusionColor, surfaceData.thickness, surfaceData.transmissionScale);
        #endif
    #endif
    ApplyRefractionLightAttenuation(radiance, NdotL, light.shadowAttenuation, surfaceData.alpha);

    #if defined(_SHADER_QUALITY_MICRO_SHADOWS) && !defined(_REFRACTION)
        half microShadows = ComputeMicroShadowing(surfaceData.occlusion, dot(vData.normalWS, light.direction), _MicroShadowOpacity);

        #ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
            radiance *= (NdotL.r * NdotL.g * NdotL.b) >= 0.0h ? microShadows : 1.0h;
        #else
            radiance *= NdotL >= 0.0h ? microShadows : 1.0h;
        #endif
    #endif

    return radiance;
}

#endif