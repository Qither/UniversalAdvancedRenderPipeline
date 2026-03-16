#ifndef URPPLUS_REFRACTION_INCLUDED
#define URPPLUS_REFRACTION_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Refraction.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Utils/DeclareGrabTexture.hlsl"

half _SSRefractionInvScreenWeightDistance;

#define HAS_REFRACTION (defined(_REFRACTION_PLANE) || defined(_REFRACTION_SPHERE) || defined(_REFRACTION_THIN))

#if HAS_REFRACTION
    // Note that this option is referred as "Box" in the UI, we are keeping _REFRACTION_PLANE as shader define to avoid complication with already created materials.
    #if defined(_REFRACTION_PLANE)
        #define REFRACTION_MODEL(inputData, bsdfData) RefractionModelBox(inputData.viewDirectionWS, inputData.positionWS, inputData.normalWS, surfaceData.ior, surfaceData.thickness)
    #elif defined(_REFRACTION_SPHERE)
        #define REFRACTION_MODEL(inputData, bsdfData) RefractionModelSphere(inputData.viewDirectionWS, inputData.positionWS, inputData.normalWS, surfaceData.ior, surfaceData.thickness)
    #elif defined(_REFRACTION_THIN)
        #define REFRACTION_THIN_DISTANCE 0.005
        #define REFRACTION_MODEL(inputData, bsdfData) RefractionModelBox(inputData.viewDirectionWS, inputData.positionWS, inputData.normalWS, surfaceData.ior, REFRACTION_THIN_DISTANCE)
    #endif
#endif

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

half3 ComputeReflectVector(float3 viewDirectionWS, float3 normalWS) 
{
    return reflect(-viewDirectionWS, normalWS);
}

half3 TransmittanceColorAtDistanceToAbsorption(half3 transmittanceColor, half atDistance)
{
    return -log(transmittanceColor + REAL_EPS) / max(atDistance, REAL_EPS);
}

bool IsInScreenSpace(float2 uv)
{
    if (uv.x > 0.0 && uv.y > 0.0 && uv.x < 1.0 && uv.y < 1.0)
    {
        return true;
    }

    return false;
}

half3 SimpleRefraction(InputData inputData, SurfaceData surfaceData, half perceptualRoughness)
{
    half4 VP = ComputeScreenPos(mul(UNITY_MATRIX_VP, half4(inputData.positionWS, 1.0h)));
    half2 screenUV = VP.xy / VP.w;
    half weight = EdgeOfScreenFade(screenUV, _SSRefractionInvScreenWeightDistance);

    float2 normalizedScreenSpaceUV = inputData.normalizedScreenSpaceUV;
#if !USE_FORWARD_PLUS
    normalizedScreenSpaceUV = float2(0.0, 0.0);
#endif
    
#if HAS_REFRACTION
    RefractionModelResult refraction = REFRACTION_MODEL(inputData, surfaceData);
    float3 hitPositionWS = refraction.positionWS + refraction.rayWS;
    float4 hitPositionCS = ComputeClipSpacePosition(hitPositionWS, GetWorldToHClipMatrix());
    float2 hitPositionNDC = ComputeNormalizedDeviceCoordinates(hitPositionWS, GetWorldToHClipMatrix());
    bool hitSuccessful = hitPositionCS.w > 0 && IsInScreenSpace(hitPositionNDC);

    half3 rgb = FetchRefractedColor(hitPositionNDC, surfaceData.chromaticAberration, perceptualRoughness);
    half3 indirectSpecular = GlossyEnvironmentReflection(refraction.rayWS, inputData.positionWS, perceptualRoughness, 1.0h, normalizedScreenSpaceUV);

    half3 absorptionCoefficient = TransmittanceColorAtDistanceToAbsorption(surfaceData.transmittanceColor, surfaceData.atDistance);
    half3 transparentTransmittance = exp(-absorptionCoefficient * refraction.dist);

    return lerp(indirectSpecular, rgb, weight * hitSuccessful) * transparentTransmittance;
#else
    half3 rgb = FetchRefractedColor(screenUV, surfaceData.chromaticAberration, perceptualRoughness);
    half3 reflectVector = ComputeReflectVector(inputData.viewDirectionWS, inputData.normalWS);
    half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, inputData.positionWS, perceptualRoughness, 1.0h, normalizedScreenSpaceUV);
    half transparentTransmittance = 1.0h;

    return lerp(indirectSpecular, rgb, weight) * transparentTransmittance;
#endif
}

void ApplyRefractionBRDF(InputData inputData, SurfaceData surfaceData, half perceptualRoughness, inout half3 diffuse)
{
    #if defined(_REFRACTION)
        half3 refractionColor = SimpleRefraction(inputData, surfaceData, perceptualRoughness);
        diffuse = lerp(refractionColor, diffuse, surfaceData.alpha);
    #endif
}

#endif