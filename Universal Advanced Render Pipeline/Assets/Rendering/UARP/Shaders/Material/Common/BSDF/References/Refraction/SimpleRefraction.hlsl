#ifndef URPPLUS_REFRACTION_INCLUDED
#define URPPLUS_REFRACTION_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Utils/DeclareGrabTexture.hlsl"

half _SSRefractionInvScreenWeightDistance;

half4 CalculateRefractionFinalColor(LightingData lightingData, half alpha)
{
    half3 finalColor = CalculateLightingColor(lightingData, 1.0h);

    return half4(finalColor, 1.0h); // Removed redundant 'alpha' since it's not used.
}

half EdgeOfScreenFade(half2 coordNDC, half fadeRcpLength)
{
    half2 coordCS = coordNDC * 2 - 1;
    half2 t = saturate((1 - abs(coordCS)) * fadeRcpLength);

    return Smoothstep01(t.x * t.y);
}

half3 FetchRefractedColor(half2 screenUV, half chromaticAberration, half iblPerceptualRoughness)
{
    half mip = PositivePow(iblPerceptualRoughness, 1.3) * uint(max(URPPLUS_SPECCUBE_LOD_STEPS - 1, 0));
    #ifdef _CHROMATIC_ABERRATION
        half3 rgb;
        half2 offset = half2(0.025 * chromaticAberration, 0);
        rgb.r = SampleGrabbedColor(screenUV, mip).r;
        rgb.g = SampleGrabbedColor(screenUV - offset, mip).g;
        rgb.b = SampleGrabbedColor(screenUV + offset, mip).b;
        
        return rgb;
    #else
        return SampleGrabbedColor(screenUV, mip).rgb;
    #endif
}

// Big thanks for reference for AE Tuts
// Ref: https://www.youtube.com/watch?v=VMsOPUUj0JA&t=106s
half3 SimpleRefraction(InputData inputData, SurfaceData surfaceData, half perceptualRoughness)
{
    half3 R = normalize(refract(inputData.viewDirectionWS, inputData.normalWS, surfaceData.ior));
    half4 RVP = ComputeScreenPos(mul(UNITY_MATRIX_VP, half4(R + inputData.positionWS, 1.0h)));
    half2 screenUV = RVP.xy / RVP.w;

    half3 rgb = FetchRefractedColor(screenUV, surfaceData.chromaticAberration, perceptualRoughness);

    half weight = EdgeOfScreenFade(screenUV, _SSRefractionInvScreenWeightDistance);
    float2 normalizedScreenSpaceUV = inputData.normalizedScreenSpaceUV;
    #if !USE_FORWARD_PLUS
    normalizedScreenSpaceUV = float2(0.0, 0.0);
    #endif
    half3 indirectSpecular = GlossyEnvironmentReflection(R, inputData.positionWS, perceptualRoughness, 1.0h, normalizedScreenSpaceUV);

    return lerp(indirectSpecular, rgb, weight) * surfaceData.transmittanceColor;
}

void ApplyRefractionBRDF(InputData inputData, SurfaceData surfaceData, half perceptualRoughness, inout half3 diffuse)
{
    #if defined(_REFRACTION)
        half3 refractionColor = SimpleRefraction(inputData, surfaceData, perceptualRoughness);
        diffuse = lerp(refractionColor, diffuse, surfaceData.alpha);
    #endif
}

#endif