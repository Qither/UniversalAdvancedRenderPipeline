#ifndef UNIVERSAL_LIGHTING_INCLUDED
#define UNIVERSAL_LIGHTING_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Data/VectorsData.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BSDF/BSDF.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BRDF/BRDF.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BRDF/ClearCoatBRDF.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Utils/Debug/Debugging3D.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/GlobalIllumination/UniversalGlobalIllumination.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/AmbientOcclusion.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BSDF/Radiance.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Lighting/LightingFunctions.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Lighting/LightingDefines.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BSDF/Refraction.hlsl"

///////////////////////////////////////////////////////////////////////////////
//                      Fragment Functions                                   //
///////////////////////////////////////////////////////////////////////////////

half4 SimpleLitFragment(InputData inputData, SurfaceData surfaceData, VectorsData vData)
{
    bool specularHighlightsOff = false;
    #if defined(_SPECULARHIGHLIGHTS_OFF)
        specularHighlightsOff = true;
    #endif

    BRDFData brdfData;

    // NOTE: can modify "surfaceData"...
    InitializeBRDFData(inputData, surfaceData, brdfData);
    ApplyRefractionBRDF(inputData, surfaceData, brdfData.perceptualRoughness, brdfData.diffuse);

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
                            brdfData.perceptualRoughness, 0.0, 0.0, indirectSpecular, coatIndirectSpecular);

    lightingData.giColor = ComplexGlobalIllumination(surfaceData, brdfData, vData, inputData.bakedGI, indirectSpecular,
                                                        coatIndirectSpecular, aoFactor.indirectAmbientOcclusion);

    #ifdef _LIGHT_LAYERS
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    #endif
    {
        lightingData.mainLightColor = SimpleLitLighting(brdfData, mainLight, inputData.normalWS,
                                                        inputData.viewDirectionWS, surfaceData.alpha,
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
            lightingData.additionalLightsColor += SimpleLitLighting(brdfData, light, inputData.normalWS, 
                                                                    inputData.viewDirectionWS, surfaceData.alpha, 
                                                                    specularHighlightsOff);
        }
    }
    #endif

    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

    #ifdef _LIGHT_LAYERS
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
    #endif
        {
            lightingData.additionalLightsColor += SimpleLitLighting(brdfData, light, inputData.normalWS, 
                                                                    inputData.viewDirectionWS, surfaceData.alpha, 
                                                                    specularHighlightsOff);
        }
    LIGHT_LOOP_END
    #endif

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
    #endif

    #if !defined(_REFRACTION)
        return CalculateFinalColor(lightingData, surfaceData.alpha);
    #else
        return CalculateRefractionFinalColor(lightingData, surfaceData.alpha);
    #endif
}

half4 ComplexLitFragment(InputData inputData, SurfaceData surfaceData, VectorsData vData)
{
    bool specularHighlightsOff = false;
    #if defined(_SPECULARHIGHLIGHTS_OFF)
        specularHighlightsOff = true;
    #endif

    BRDFData brdfData;

    // NOTE: can modify "surfaceData"...
    InitializeBRDFData(inputData, surfaceData, brdfData);
    ApplyRefractionBRDF(inputData, surfaceData, brdfData.perceptualRoughness, brdfData.diffuse);

    #if defined(DEBUG_DISPLAY)
    half4 debugColor;

    if (CanDebugOverrideOutputColor(inputData, surfaceData, brdfData, debugColor))
    {
        return debugColor;
    }
    #endif

    BRDFData brdfDataClearCoat = CreateClearCoatBRDFData(surfaceData, brdfData);
    
    half4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
    uint meshRenderingLayers = GetMeshRenderingLayer();
    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);

    // NOTE: We don't apply AO to the GI here because it's done in the lighting calculation below...
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);
    LightingData lightingData = CreateLightingData(inputData, surfaceData);
    
    half3 indirectSpecular, coatIndirectSpecular;
    ComputeIndirectSpecular(vData, inputData.positionWS, inputData.normalizedScreenSpaceUV, brdfData.perceptualRoughness, 
                            brdfDataClearCoat.perceptualRoughness, surfaceData.anisotropy, indirectSpecular, coatIndirectSpecular);

    lightingData.giColor = ComplexGlobalIllumination(surfaceData, brdfData, brdfDataClearCoat, vData, inputData.bakedGI, 
                                                        indirectSpecular, coatIndirectSpecular, aoFactor.indirectAmbientOcclusion);

    #ifdef _LIGHT_LAYERS
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    #endif
    {
        lightingData.mainLightColor = ComplexLitLighting(surfaceData, brdfData, brdfDataClearCoat, 
                                                            vData, mainLight, specularHighlightsOff);
        #ifdef _MATERIAL_FEATURE_TRANSLUCENCY
        lightingData.mainLightColor += Translucency(surfaceData, mainLight, brdfData.diffuse, inputData.normalWS, inputData.viewDirectionWS);
        #endif
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
            lightingData.additionalLightsColor += ComplexLitLighting(surfaceData, brdfData, brdfDataClearCoat, 
                                                            vData, light, specularHighlightsOff);
            #ifdef _MATERIAL_FEATURE_TRANSLUCENCY
            lightingData.additionalLightsColor += Translucency(surfaceData, light, brdfData.diffuse, inputData.normalWS, inputData.viewDirectionWS);
            #endif
        }
    }
    #endif

    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

    #ifdef _LIGHT_LAYERS
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
    #endif
        {
            lightingData.additionalLightsColor += ComplexLitLighting(surfaceData, brdfData, brdfDataClearCoat, 
                                                            vData, light, specularHighlightsOff);
            #ifdef _MATERIAL_FEATURE_TRANSLUCENCY
            lightingData.additionalLightsColor += Translucency(surfaceData, light, brdfData.diffuse, inputData.normalWS, inputData.viewDirectionWS);
            #endif
        }
    LIGHT_LOOP_END
    #endif

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
    #endif

    #if !defined(_REFRACTION)
        return CalculateFinalColor(lightingData, surfaceData.alpha);
    #else
        return CalculateRefractionFinalColor(lightingData, surfaceData.alpha);
    #endif
}

#endif
