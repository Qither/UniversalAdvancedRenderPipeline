#ifndef URPPLUS_BSDF_INCLUDED
#define URPPLUS_BSDF_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/BSDF.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonLighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BSDF/Iridescence.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BSDF/GeometricAA.hlsl"

#define CLEAR_COAT_IOR 1.5

half _MicroShadowOpacity;

half3 IridescenceSpecular(half3 normalWS, half3 viewDirectionWS, half3 specular, half3 iridescenceTMS, half clearCoatMask)
{
    half NdotV = dot(normalWS, viewDirectionWS);
    half clampedNdotV = ClampNdotV(NdotV);
    half viewAngle = clampedNdotV;
    half topIor = 1.0;

    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    topIor = lerp(1.0, CLEAR_COAT_IOR, clearCoatMask);
    viewAngle = sqrt(1.0 + Sq(1.0 / topIor) * (Sq(NdotV) - 1.0));
    #endif

    if (iridescenceTMS.y > 0.0)
    {
        specular = lerp(specular, CalculateIridescence(topIor, viewAngle, iridescenceTMS.xz, specular), iridescenceTMS.y);
    }

    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    specular = lerp(specular, ConvertF0ForAirInterfaceToF0ForClearCoat15Fast(specular), clearCoatMask);
    #endif
    
    return specular;
}

half DV_Anisotropy(VectorsData vData, half perceptualRoughness, half anisotropy, half3 lightDirWS)
{
    float3 H = SafeNormalize(float3(lightDirWS) + float3(vData.viewDirectionWS));
    half3 bitangentWS = cross(vData.normalWS, vData.tangentWS.xyz);

    half NdotL = dot(vData.normalWS, lightDirWS);
    half clampedNdotV = ClampNdotV(dot(vData.normalWS, vData.viewDirectionWS));
    half NdotH = saturate(dot(vData.normalWS, H));
    
    half roughnessT;
    half roughnessB;
    ConvertAnisotropyToRoughness(perceptualRoughness, anisotropy, roughnessT, roughnessB);

    half TdotH = dot(vData.tangentWS.xyz, H);
    half TdotL = dot(vData.tangentWS.xyz, lightDirWS);
    half TdotV = dot(vData.tangentWS.xyz, vData.viewDirectionWS);
    half BdotH = dot(bitangentWS, H);
    half BdotL = dot(bitangentWS, lightDirWS);
    half BdotV = dot(bitangentWS, vData.viewDirectionWS);

    roughnessT = max(0.01, roughnessT);
    roughnessB = max(0.01, roughnessB);

    half partLambdaV = GetSmithJointGGXAnisoPartLambdaV(TdotV, BdotV, clampedNdotV, roughnessT, roughnessB);
    half DV = DV_SmithJointGGXAniso(TdotH, BdotH, NdotH, clampedNdotV, TdotL, BdotL, abs(NdotL), roughnessT, roughnessB,
                                    partLambdaV);

    return max(0, DV);
}

#endif