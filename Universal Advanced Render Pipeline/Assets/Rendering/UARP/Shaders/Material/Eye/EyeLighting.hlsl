#ifndef UNIVERSAL_LIGHTING_INCLUDED
#define UNIVERSAL_LIGHTING_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Data/VectorsData.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BSDF/BSDF.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BRDF/BRDF.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Utils/Debug/Debugging3D.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/GlobalIllumination/UniversalGlobalIllumination.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/AmbientOcclusion.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BSDF/Radiance.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Lighting/LightingFunctions.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Eye/EyeUtils.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Lighting/LightingDefines.hlsl"

half3 EyeLighting(BRDFData brdfData, Light light, half3 diffuseNormalWS, half3 specularNormalWS, half3 viewDirectionWS, bool specularHighlightsOff)
{
    half irisNdotL = ComputeWrappedPowerDiffuseLighting(dot(diffuseNormalWS, light.direction), EYEWRAP, 2.0h);
    half scleraNdotL = saturate(dot(specularNormalWS, light.direction));
    half3 brdf = brdfData.diffuse * irisNdotL;

    #ifndef _SPECULARHIGHLIGHTS_OFF
    [branch] if (!specularHighlightsOff)
    {
        brdf += DirectBRDFSpecular(brdfData, specularNormalWS, light.direction, viewDirectionWS, brdfData.specular);
    }
    #endif // _SPECULARHIGHLIGHTS_OFF

    half lightAttenuation = light.distanceAttenuation * light.shadowAttenuation;
    half3 radiance = light.color * (lightAttenuation * scleraNdotL);

    return brdf * radiance;
}

///////////////////////////////////////////////////////////////////////////////
//                      Fragment Functions                                   //
///////////////////////////////////////////////////////////////////////////////

half4 EyeFragment(InputData inputData, SurfaceData surfaceData, VectorsData vData, float3 diffuseNormalWS, float3 specularNormalWS)
{
    bool specularHighlightsOff = false;
    #if defined(_SPECULARHIGHLIGHTS_OFF)
        specularHighlightsOff = true;
    #endif

    BRDFData brdfData;

    // NOTE: can modify "surfaceData"...
    InitializeBRDFData(inputData, surfaceData, brdfData);

    #if defined(DEBUG_DISPLAY)
    half4 debugColor;

    if (CanDebugOverrideOutputColor(inputData, surfaceData, brdfData, debugColor))
    {
        return debugColor;
    }
    #endif

    half4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
    uint meshRenderingLayers = GetMeshRenderingLayer();
    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);

    // NOTE: We don't apply AO to the GI here because it's done in the lighting calculation below...
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);
    LightingData lightingData = CreateLightingData(inputData, surfaceData);
    
    half3 indirectSpecular, coatIndirectSpecular;
    ComputeIndirectSpecular(vData, inputData.positionWS, inputData.normalizedScreenSpaceUV, 
                            brdfData.perceptualRoughness, 0.0, surfaceData.anisotropy, 
                            indirectSpecular, coatIndirectSpecular);

    lightingData.giColor = ComplexGlobalIllumination(surfaceData, brdfData, vData, inputData.bakedGI, indirectSpecular,
                                                        coatIndirectSpecular, aoFactor.indirectAmbientOcclusion);

    #ifdef _LIGHT_LAYERS
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    #endif
    {
        lightingData.mainLightColor = EyeLighting(brdfData, mainLight, diffuseNormalWS, specularNormalWS, inputData.viewDirectionWS,
                                                    specularHighlightsOff);
    }

    #if defined(_ADDITIONAL_LIGHTS)
    uint pixelLightCount = GetAdditionalLightsCount();

    #if USE_FORWARD_PLUS
    for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
    {
        FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

    #ifdef _LIGHT_LAYERS
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
    #endif
        {
            lightingData.additionalLightsColor += EyeLighting(brdfData, light, diffuseNormalWS, specularNormalWS,
                                                                inputData.viewDirectionWS, specularHighlightsOff);
        }
    }
    #endif

    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

    #ifdef _LIGHT_LAYERS
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
    #endif
        {
            lightingData.additionalLightsColor += EyeLighting(brdfData, light, diffuseNormalWS, specularNormalWS,
                                                                 inputData.viewDirectionWS, specularHighlightsOff);
        }
    LIGHT_LOOP_END
    #endif

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
    #endif

    return CalculateFinalColor(lightingData, surfaceData.alpha);
}

#endif