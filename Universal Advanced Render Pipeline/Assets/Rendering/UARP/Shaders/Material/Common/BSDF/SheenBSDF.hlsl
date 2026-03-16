#ifndef URPPLUS_SHEEN_INCLUDED
#define URPPLUS_SHEEN_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonLighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/BSDF.hlsl"

//CharlieDV
half3 SheenBSDF(half3 viewDirWS, half3 lightDirWS, half3 normalWS, half3 specular, half perceptualRoughness)
{
    half LdotV, NdotH, LdotH, invLenLV;

    half NdotL = saturate(dot(normalWS, lightDirWS));
    half NdotV = saturate(dot(normalWS, viewDirWS));
    half clampedNdotV = ClampNdotV(NdotV);

    GetBSDFAngle(viewDirWS, lightDirWS, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);
    
    half roughness = max(PerceptualRoughnessToRoughness(perceptualRoughness), HALF_MIN_SQRT);

    half D = D_CharlieNoPI(NdotH, roughness);
    half V = V_Ashikhmin(NdotL, clampedNdotV);
    half3 F = F_Schlick(specular, LdotH);

    half3 Fr = saturate(V * D) * F;
    
    return Fr;
}

#endif