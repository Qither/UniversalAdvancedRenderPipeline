#ifndef URPPLUS_DIFFUSION_INCLUDED
#define URPPLUS_DIFFUSION_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/SubsurfaceScattering/Includes/SubsurfaceScattering.hlsl"

#ifndef UARP_DIFFUSION_PROFILE_HASH_DECLARED
#define UARP_DIFFUSION_PROFILE_HASH_DECLARED
float _DiffusionProfileHash;
#endif

#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING)

half3 SubSurfaceScattering(SurfaceData surfaceData, BRDFData brdfData, Light light, half3 normalWS)
{
    uint diffusionProfileIndex = GetDiffusionProfileIndex(_DiffusionProfileHash);
    half wrappedNdotL = saturate(dot(normalWS, light.direction) * 0.5h + 0.5h);

    if (_EnableSubsurfaceScattering == 0 || diffusionProfileIndex == 0)
    {
        return wrappedNdotL.xxx;
    }

    float sampleRadius = max(surfaceData.curvature, 0.001h) * max(GetFilterRadius(diffusionProfileIndex), 0.001f);
    float3 profileScatter = EvalBurleyDiffusionProfile(sampleRadius, GetShapeParam(diffusionProfileIndex));
    half3 diffuse = saturate((half3)profileScatter + wrappedNdotL.xxx * surfaceData.diffusionColor);

    return diffuse;
}

half3 Transmission(Light light, half3 normalWS, half3 subsurfaceColor, half thickness, half scale)
{
    half NdotL = max(0, -dot(light.direction, normalWS));
    uint diffusionProfileIndex = GetDiffusionProfileIndex(_DiffusionProfileHash);

    if (_EnableSubsurfaceScattering == 0 || diffusionProfileIndex == 0)
    {
        half backLight = NdotL * (1.0h - thickness);
        return backLight * light.color * scale * subsurfaceColor;
    }

    half2 thicknessRemap = (half2)GetThicknessRemap(diffusionProfileIndex);
    half remappedThickness = thicknessRemap.x + thicknessRemap.y * thickness;
    half3 transmittance = (half3)ComputeTransmittanceDisney(GetShapeParam(diffusionProfileIndex),
                                                            GetTransmissionTint(diffusionProfileIndex),
                                                            remappedThickness);
    half3 result = NdotL * light.color * scale * transmittance;
    
    return result;
}

#endif

/**************Translucency**************/
//ref: https://colinbarrebrisebois.com/2012/04/09/approximating-translucency-revisited-with-simplified-spherical-gaussian/
//ref: https://github.com/google/filament/blob/24b88219fa6148b8004f230b377f163e6f184d65/shaders/src/shading_model_subsurface.fs
half3 Translucency(SurfaceData surfaceData, Light light, half3 diffuse, half3 normalWS, half3 viewDirWS)
{
    half invThickness = 1.0h - surfaceData.thickness;
    half lightAttenuation = light.distanceAttenuation * lerp(1.0h, light.shadowAttenuation, surfaceData.translucencyShadows);

    half NdotL = max(0.0h, dot(normalWS, light.direction));
    half3 translucencyAttenuation = surfaceData.diffusionColor * light.color * lightAttenuation;

    half3 H = normalize(-light.direction + normalWS * surfaceData.translucencyDistortion);
    half nonNormalizedVdotH = dot(viewDirWS, H);
    half VdotH = max(0.0h, nonNormalizedVdotH);
    half forwardScatter = exp2(VdotH * surfaceData.translucencyPower - surfaceData.translucencyPower) * surfaceData.translucencyScale;
    
    half backScatter = max(0.0h, NdotL * surfaceData.thickness + invThickness) * 0.5h;
    half subsurface = lerp(backScatter, 1.0h, forwardScatter) * invThickness;
    
    half3 fLT = (0.3183h * subsurface + surfaceData.translucencyAmbient) * translucencyAttenuation;
    half3 cLT = fLT * lerp(1.0h, diffuse, surfaceData.translucencyDiffuseInfluence);

    return cLT * invThickness;
}

#endif
