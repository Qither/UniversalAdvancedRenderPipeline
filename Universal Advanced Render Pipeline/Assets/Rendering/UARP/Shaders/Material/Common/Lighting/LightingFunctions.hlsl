#ifndef URPPLUS_LIGHT_FUNCTIONS_INCLUDED
#define URPPLUS_LIGHT_FUNCTIONS_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/BSDF/Radiance.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Lighting/LightingData.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BRDF/BRDFSpecular.hlsl"

half3 LightingLambert(half3 lightColor, half3 lightDir, half3 normal)
{
    half NdotL = saturate(dot(normal, lightDir));
    return lightColor * NdotL;
}

half3 LightingSpecular(half3 lightColor, half3 lightDir, half3 normal, half3 viewDir, half4 specular, half smoothness)
{
    float3 halfVec = SafeNormalize(float3(lightDir) + float3(viewDir));
    half NdotH = half(saturate(dot(normal, halfVec)));
    half modifier = pow(NdotH, smoothness);
    half3 specularReflection = specular.rgb * modifier;
    return lightColor * specularReflection;
}

half3 SimpleLitLighting(BRDFData brdfData, Light light, half3 normalWS, half3 viewDirectionWS, half alpha,
                        bool specularHighlightsOff)
{
    half3 radiance = ComputeRadiance(light, normalWS, alpha);
    half3 brdf = brdfData.diffuse;
    #ifndef _SPECULARHIGHLIGHTS_OFF
    [branch] if (!specularHighlightsOff)
    {
        brdf += DirectBRDFSpecular(brdfData, normalWS, light.direction, viewDirectionWS, brdfData.specular);
    }
    #endif // _SPECULARHIGHLIGHTS_OFF

    return brdf * radiance;
}

half3 ComplexLitLighting(SurfaceData surfaceData, BRDFData brdfData, VectorsData vData, Light light,
                            bool specularHighlightsOff)
{
    half3 radiance = ComputeComplexRadiance(surfaceData, brdfData, vData, light);
    half3 brdf = brdfData.diffuse;
    #ifndef _SPECULARHIGHLIGHTS_OFF
    [branch] if (!specularHighlightsOff)
    {
        brdf += ComplexDirectBRDFSpecular(brdfData, vData, light.direction, brdfData.specular, surfaceData.anisotropy);
    }
    #endif // _SPECULARHIGHLIGHTS_OFF

    return brdf * radiance;
}

half3 ComplexLitLighting(SurfaceData surfaceData, BRDFData brdfData, BRDFData brdfDataCoat, VectorsData vData,
                            Light light, bool specularHighlightsOff)
{
    half3 radiance = ComputeComplexRadiance(surfaceData, brdfData, vData, light);
    half3 brdf = brdfData.diffuse;
    #ifndef _SPECULARHIGHLIGHTS_OFF
    [branch] if (!specularHighlightsOff)
    {
        brdf += ComplexDirectBRDFSpecular(brdfData, vData, light.direction, brdfData.specular, surfaceData.anisotropy);

        brdf = ApplyClearCoatBRDF(surfaceData, brdfDataCoat, vData, brdf, light.direction);
    }
    #endif // _SPECULARHIGHLIGHTS_OFF

    return brdf * radiance;
}

half3 CalculateBlinnPhong(Light light, InputData inputData, SurfaceData surfaceData)
{
    half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
    half3 lightDiffuseColor = LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);

    half3 lightSpecularColor = half3(0, 0, 0);
    #if defined(_SPECGLOSSMAP) || defined(_SPECULAR_COLOR)
    half smoothness = exp2(10 * surfaceData.smoothness + 1);

    lightSpecularColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, half4(surfaceData.specular, 1), smoothness);
    #endif

    #if _ALPHAPREMULTIPLY_ON
    return lightDiffuseColor * surfaceData.albedo * surfaceData.alpha + lightSpecularColor;
    #else
    return lightDiffuseColor * surfaceData.albedo + lightSpecularColor;
    #endif
}

half3 VertexLighting(float3 positionWS, half3 normalWS)
{
    half3 vertexLightColor = half3(0.0, 0.0, 0.0);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
    uint lightsCount = GetAdditionalLightsCount();
    LIGHT_LOOP_BEGIN(lightsCount)
        Light light = GetAdditionalLight(lightIndex, positionWS);
        half3 lightColor = light.color * light.distanceAttenuation;
        vertexLightColor += LightingLambert(lightColor, light.direction, normalWS);
    LIGHT_LOOP_END
    #endif

    return vertexLightColor;
}

#endif