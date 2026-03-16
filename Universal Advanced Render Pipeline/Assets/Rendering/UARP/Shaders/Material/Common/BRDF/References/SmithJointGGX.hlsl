#ifndef URPPLUS_BRDF_SPECULAR_INCLUDED
#define URPPLUS_BRDF_SPECULAR_INCLUDED

half3 DirectBRDFSpecular(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS, half3 specular)
{
    float3 lightDir = float3(lightDirectionWS);
    float3 halfDir = SafeNormalize(lightDir + float3(viewDirectionWS));

    float NdotH = saturate(dot(float3(normalWS), halfDir));
    half LdotH = half(saturate(dot(lightDir, halfDir)));
    float NdotL = dot(normalWS, lightDirectionWS);
    float NdotV = dot(normalWS, viewDirectionWS);
    float clampedNdotV = saturate(NdotV);
    
    float partLambdaV = GetSmithJointGGXPartLambdaV(clampedNdotV, brdfData.roughness);

    half3 F = F_Schlick(specular, LdotH);
    float DV = DV_SmithJointGGX(NdotH, abs(NdotL), clampedNdotV, brdfData.roughness, partLambdaV);
    half3 specularTerm = DV * F;

    #if REAL_IS_HALF
    specularTerm = clamp(specularTerm - HALF_MIN, 0.0, 1000.0); // Prevent FP16 overflow on mobiles
    #endif

    return specularTerm;
}

half3 ComplexDirectBRDFSpecular(BRDFData brdfData, VectorsData vData, half3 lightDirectionWS, half3 specular, half anisotropy)
{
    float3 lightDir = float3(lightDirectionWS);
    float3 halfDir = SafeNormalize(lightDir + float3(vData.viewDirectionWS));

    float NdotH = saturate(dot(float3(vData.normalWS), halfDir));
    half LdotH = half(saturate(dot(lightDir, halfDir)));
    float NdotL = dot(vData.normalWS, lightDirectionWS);
    float NdotV = dot(vData.normalWS, vData.viewDirectionWS);
    float clampedNdotV = saturate(NdotV);
    
    float partLambdaV = GetSmithJointGGXPartLambdaV(clampedNdotV, brdfData.roughness);

    half3 F = F_Schlick(specular, LdotH);
    #ifdef _MATERIAL_FEATURE_ANISOTROPY
    float DV = DV_Anisotropy(vData, brdfData.perceptualRoughness, anisotropy, lightDir);
    #else
    float DV = DV_SmithJointGGX(NdotH, abs(NdotL), clampedNdotV, brdfData.roughness, partLambdaV);
    #endif

    half3 specularTerm = DV * F;

    #if REAL_IS_HALF
    specularTerm = clamp(specularTerm - HALF_MIN, 0.0, 1000.0); // Prevent FP16 overflow on mobiles
    #endif

    return specularTerm;
}

inline half3 DirectBDRF(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS,
                 bool specularHighlightsOff)
{
    // Can still do compile-time optimisation.
    // If no compile-time optimized, extra overhead if branch taken is around +2.5% on some untethered platforms, -10% if not taken.
    [branch] if (!specularHighlightsOff)
    {
        half3 specularTerm = DirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS, brdfData.specular);
        return brdfData.diffuse + specularTerm;
    }
    return brdfData.diffuse;
}

inline half3 DirectBRDF(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    #ifndef _SPECULARHIGHLIGHTS_OFF
    half3 specularTerm = DirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS, brdfData.specular);
    return brdfData.diffuse + specularTerm;
    #else
    return brdfData.diffuse;
    #endif
}

inline half3 ComplexDirectBRDF(BRDFData brdfData, VectorsData vData, half3 lightDirectionWS, half anisotropy, bool specularHighlightsOff)
{
    // Can still do compile-time optimisation.
    // If no compile-time optimized, extra overhead if branch taken is around +2.5% on some untethered platforms, -10% if not taken.
    [branch] if (!specularHighlightsOff)
    {
        half3 specularTerm = ComplexDirectBRDFSpecular(brdfData, vData, lightDirectionWS, brdfData.specular, anisotropy);
        return brdfData.diffuse + specularTerm;
    }
    return brdfData.diffuse;
}

inline half3 ComplexDirectBRDF(BRDFData brdfData, VectorsData vData, half3 lightDirectionWS, half anisotropy)
{
    #ifndef _SPECULARHIGHLIGHTS_OFF
    return brdfData.diffuse + ComplexDirectBRDFSpecular(brdfData, vData, lightDirectionWS, brdfData.specular, anisotropy);
    #else
    return brdfData.diffuse;
    #endif
}

inline half3 ApplyClearCoatBRDF(SurfaceData surfaceData, BRDFData brdfDataCoat, VectorsData vData, half3 brdf, half3 lightDir)
{
    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
        half3 clearCoatNormalWS = vData.normalWS;
        #if defined(_COATNORMALMAP)
            clearCoatNormalWS = vData.coatNormalWS;
        #endif
    
        half3 brdfCoat = DirectBRDFSpecular(brdfDataCoat, clearCoatNormalWS, lightDir, vData.viewDirectionWS, kDielectricSpec.rrr);
        half NoV = saturate(dot(clearCoatNormalWS, vData.viewDirectionWS));
    
        half coatFresnel = kDielectricSpec.x + kDielectricSpec.a * Pow4(1.0 - NoV);
    
        return brdf * (1.0 - surfaceData.clearCoatMask * coatFresnel) + brdfCoat * surfaceData.clearCoatMask;
    #else
        return brdf;
    #endif // _CLEARCOAT
}

#endif