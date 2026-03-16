#ifndef UNIVERSAL_LIGHTING_INCLUDED
#define UNIVERSAL_LIGHTING_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Data/VectorsData.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BSDF/BSDF.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BSDF/SheenBSDF.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BRDF/BRDF.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Fabric/FabricDebugging3D.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Fabric/FabricGlobalIllumination.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/AmbientOcclusion.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/BSDF/Radiance.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Lighting/LightingFunctions.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Lighting/LightingDefines.hlsl"

half3 DirectFabricBRDFSpecular(VectorsData vData, half3 lightDirectionWS, half3 specular, half perceptualRoughness, half anisotropy)
{
    #ifdef _MATERIAL_FEATURE_SHEEN
    half3 specularFabric = SheenBSDF(vData.viewDirectionWS, lightDirectionWS, vData.normalWS, specular, perceptualRoughness);
    #else
    half3 specularFabric = specular * DV_Anisotropy(vData, perceptualRoughness, anisotropy, lightDirectionWS);
    #endif

    return specularFabric;
}

half3 FabricLighting(SurfaceData surfaceData, BRDFData brdfData, VectorsData vData, Light light, bool specularHighlightsOff)
{
    half3 radiance = ComputeRadiance(light, vData.normalWS, surfaceData.alpha);
    half3 brdf = brdfData.diffuse;
    #ifndef _SPECULARHIGHLIGHTS_OFF
    [branch] if (!specularHighlightsOff)
    {
        brdf += DirectFabricBRDFSpecular(vData, light.direction, brdfData.specular, brdfData.perceptualRoughness, surfaceData.anisotropy);
    }
    #endif // _SPECULARHIGHLIGHTS_OFF

    return brdf * radiance;
}

///////////////////////////////////////////////////////////////////////////////
//                      Fragment Functions                                   //
///////////////////////////////////////////////////////////////////////////////

half4 FabricFragment(InputData inputData, SurfaceData surfaceData, VectorsData vData)
{
    bool specularHighlightsOff = false;
    #if defined(_SPECULARHIGHLIGHTS_OFF)
        specularHighlightsOff = true;
    #endif

    BRDFData brdfData;

    // NOTE: can modify "surfaceData"...
    InitializeFabricBRDFData(surfaceData, brdfData);

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
    
    lightingData.giColor = FabricGI(surfaceData, brdfData, vData, inputData.positionWS, inputData.bakedGI, 
                                    inputData.normalizedScreenSpaceUV, aoFactor.indirectAmbientOcclusion);

    #ifdef _LIGHT_LAYERS
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    #endif
    {
        lightingData.mainLightColor = FabricLighting(surfaceData, brdfData, vData, mainLight, specularHighlightsOff);
        #ifdef _MATERIAL_FEATURE_TRANSLUCENCY
            lightingData.mainLightColor += Translucency(surfaceData, mainLight, brdfData.diffuse, vData.normalWS, 
                                                        vData.viewDirectionWS);
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
            lightingData.additionalLightsColor += FabricLighting(surfaceData, brdfData, vData, light, specularHighlightsOff);
            #ifdef _MATERIAL_FEATURE_TRANSLUCENCY
                lightingData.additionalLightsColor += Translucency(surfaceData, light, brdfData.diffuse, vData.normalWS, 
                                                                    vData.viewDirectionWS);
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
            lightingData.additionalLightsColor += FabricLighting(surfaceData, brdfData, vData, light, specularHighlightsOff);
            #ifdef _MATERIAL_FEATURE_TRANSLUCENCY
                lightingData.additionalLightsColor += Translucency(surfaceData, light, brdfData.diffuse, inputData.normalWS, 
                                                                    inputData.viewDirectionWS);
            #endif
        }
    LIGHT_LOOP_END
    #endif

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
    #endif

    return CalculateFinalColor(lightingData, surfaceData.alpha);
}

#endif