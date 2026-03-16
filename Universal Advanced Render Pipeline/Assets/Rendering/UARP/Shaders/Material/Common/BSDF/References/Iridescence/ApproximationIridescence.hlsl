#ifndef URPPLUS_IRIDESCENCE_INCLUDED
#define URPPLUS_IRIDESCENCE_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/BSDF.hlsl"

TEXTURE2D(_IridescenceLUT);             SAMPLER(sampler_IridescenceLUT);

half3 CalculateIridescence(half eta_1, half cosTheta1, half2 iridescenceTS, half3 specular)
{
    half eta_2 = 2.0 - iridescenceTS.x;
    half sinTheta2Sq = Sq(eta_1 / eta_2) * (1.0 - Sq(cosTheta1));
    half cosTheta2 = sqrt(saturate(1.0 - sinTheta2Sq));
    half k = iridescenceTS.y + (cosTheta2 * (PI * iridescenceTS.x));
    half R0 = IorToFresnel0(eta_2, eta_1);
    half R12 = saturate(sqrt(F_Schlick(R0, cosTheta1)));

    half3 iridescenceColor = SAMPLE_TEXTURE2D(_IridescenceLUT, sampler_IridescenceLUT, float2(k * 1.5, 1.0)).rgb - 0.2;
    half3 resultColor = lerp(specular, iridescenceColor, R12);

    return resultColor;
}

#endif