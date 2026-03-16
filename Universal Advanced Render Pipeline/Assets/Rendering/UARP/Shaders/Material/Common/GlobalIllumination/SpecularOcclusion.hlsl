#ifndef URPPLUS_SPECULAR_OCCLUSION_INCLUDED
#define URPPLUS_SPECULAR_OCCLUSION_INCLUDED

half GetLuminance(half3 colorLinear)
{
    #if _TONEMAP_ACES
        return AcesLuminance(colorLinear);
    #else
        return Luminance(colorLinear);
    #endif
}

half SpecularOcclusionFromGI(half3 indirectSpecular, half3 bakedGI, half giOcclusionBias)
{
    half exposure = PI + GetLuminance(indirectSpecular);

    return saturate((giOcclusionBias + GetLuminance(bakedGI)) * exposure);
}

half CalculateSpecularOcclusion(BRDFData brdfData, SurfaceData surfaceData, VectorsData vData, 
                                half3 indirectSpecular, half3 bakedGI, half occlusion)
{
    half specularOcclusion = 1.0;

    #if defined(_AO_SPECULAR_OCCLUSION)
        half NdotV = saturate(dot(vData.normalWS, vData.viewDirectionWS));
        specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(NdotV, occlusion, brdfData.roughness);
    #elif defined(_GI_SPECULAR_OCCLUSION)
        specularOcclusion = SpecularOcclusionFromGI(indirectSpecular, bakedGI, surfaceData.giOcclusionBias);
    #endif

    #ifdef _HORIZON_SPECULAR_OCCLUSION
        specularOcclusion *= GetHorizonOcclusion(vData.viewDirectionWS, vData.normalWS, vData.geomNormalWS, surfaceData.horizonFade);
    #endif

    return specularOcclusion;
}

#endif