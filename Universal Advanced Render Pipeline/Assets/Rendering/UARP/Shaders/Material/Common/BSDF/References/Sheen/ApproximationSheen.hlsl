#ifndef URPPLUS_SHEEN_INCLUDED
#define URPPLUS_SHEEN_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/BSDF.hlsl"

/*half3 SheenVD(half NoH, half smoothness)
{
    const half a = 0.22h;
    const half b = 0.585h;
    const half c = 0.75h;
    const half d = 1.25h;
    const half cTimesSmoothness = c + d * smoothness; // Precompute c + d * smoothness
    const half aTimesSmoothness = a + b * smoothness; // Precompute a + b * smoothness

    half f = exp2(-5.55473h * NoH * NoH); // Approximate pow(1.0 - NoH, cTimesSmoothness)
    half sheen = aTimesSmoothness * f; // Avoid the saturate operation

    return sheen * PI;
}*/

half3 SheenVD(half NoH, half smoothness)
{
    const half a = 0.22h;
    const half b = 0.585h;
    const half c = 0.75h;
    const half d = 1.25h;

    half f = pow(1.0h - NoH, c + d * smoothness);
    half sheen = saturate((a + b * smoothness) * f);

    return sheen * PI;
}

half3 SheenBSDF(half3 viewDirWS, half3 lightDirWS, half3 normalWS, half3 specular, half perceptualRoughness)
{
    float3 halfDir = SafeNormalize(float3(lightDirWS) + float3(viewDirWS));
    float NoH = saturate(dot(normalWS, halfDir));
    half LoH = saturate(dot(lightDirWS, halfDir));
    half3 F = F_Schlick(specular, LoH);
    half smoothness = PerceptualRoughnessToPerceptualSmoothness(perceptualRoughness);
    
    return SheenVD(NoH, smoothness) * F;
}

#endif