#ifndef SSSLIT_FORWARD_PASS_INCLUDED
#define SSSLIT_FORWARD_PASS_INCLUDED

// Include SSSLitInput first (contains UnityPerMaterial CBUFFER for SRP Batcher)
#include "Assets/Rendering/UARP/Shaders/Material/SubsurfaceScattering/Includes/SSSLitInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/SubsurfaceScattering/Includes/SubsurfaceScattering.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif

#if defined(_PARALLAXMAP)
#define REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR
#endif

#if (defined(_NORMALMAP) || (defined(_PARALLAXMAP) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR))) || defined(_DETAIL)
#define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif

// keep this file in sync with LitForwardPass.hlsl

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 staticLightmapUV   : TEXCOORD1;
    float2 dynamicLightmapUV  : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    float3 positionWS               : TEXCOORD1;
#endif

    float3 normalWS                 : TEXCOORD2;
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    half4 tangentWS                : TEXCOORD3;    // xyz: tangent, w: sign
#endif

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    half4 fogFactorAndVertexLight   : TEXCOORD5; // x: fogFactor, yzw: vertex light
#else
    half  fogFactor                 : TEXCOORD5;
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord              : TEXCOORD6;
#endif

#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS                : TEXCOORD7;
#endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
#ifdef DYNAMICLIGHTMAP_ON
    float2  dynamicLightmapUV : TEXCOORD9; // Dynamic lightmap UVs
#endif

#ifdef USE_APV_PROBE_OCCLUSION
    float4 probeOcclusion : TEXCOORD10;
#endif

    float4 positionCS               : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    inputData.positionWS = input.positionWS;
#endif

#if defined(DEBUG_DISPLAY)
    inputData.positionCS = input.positionCS;
#endif

    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
#if defined(_NORMALMAP) || defined(_DETAIL)
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

    #if defined(_NORMALMAP)
    inputData.tangentToWorld = tangentToWorld;
    #endif
    inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
#else
    inputData.normalWS = input.normalWS;
#endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    inputData.viewDirectionWS = viewDirWS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactorAndVertexLight.x);
    inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
#else
    inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
#endif

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

    #if defined(DEBUG_DISPLAY)
    #if defined(DYNAMICLIGHTMAP_ON)
    inputData.dynamicLightmapUV = input.dynamicLightmapUV;
    #endif
    #if defined(LIGHTMAP_ON)
    inputData.staticLightmapUV = input.staticLightmapUV;
    #else
    inputData.vertexSH = input.vertexSH;
    #endif
    #endif

#ifdef USE_APV_PROBE_OCCLUSION
    inputData.probeOcclusion = input.probeOcclusion;
#endif
}

void InitializeBakedGIData(Varyings input, inout InputData inputData)
{
    #if defined(DYNAMICLIGHTMAP_ON)
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, inputData.normalWS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
    #elif !defined(LIGHTMAP_ON) && (defined(PROBE_VOLUMES_L1) || defined(PROBE_VOLUMES_L2))
    inputData.bakedGI = SAMPLE_GI(input.vertexSH,
        GetAbsolutePositionWS(inputData.positionWS),
        inputData.normalWS,
        inputData.viewDirectionWS,
        input.positionCS.xy,
        input.probeOcclusion,
        inputData.shadowMask);
    #else
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
    #endif
}

// Custom InitializeBRDFData for SSS that overrides fresnel0 from diffusion profile
// Following HDRP approach: use IOR-based fresnel0 from diffusion profile instead of material specular color
// Ref: HDRP FillMaterialSSS() in SubsurfaceScattering.hlsl
inline void InitializeBRDFDataSSS(inout SurfaceData surfaceData, uint diffusionProfileIndex, float subsurfaceMask, out BRDFData brdfData)
{
    // First, initialize BRDF data using standard URP method
    InitializeBRDFData(surfaceData, brdfData);
    
    // Then override specular (f0) with fresnel0 from diffusion profile (following HDRP approach)
    // This ensures all BRDF calculations use the correct f0 value derived from the profile's IOR
    float fresnel0 = _TransmissionTintsAndFresnel0[diffusionProfileIndex].a;
    brdfData.specular = fresnel0;
    
    // Recalculate reflectivity and grazingTerm based on new specular value
    brdfData.reflectivity = fresnel0;
    brdfData.grazingTerm = saturate(surfaceData.smoothness + fresnel0);
    
    // Apply SSS texturing mode to diffuse color using the existing helper function
    brdfData.diffuse = GetModifiedDiffuseColorForSSS(brdfData.diffuse, subsurfaceMask, diffusionProfileIndex);
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Physically Based) shader
Varyings SSSBufferVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);

    half fogFactor = 0;
#if !defined(_FOG_FRAGMENT)
        fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
#endif

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    real sign = input.tangentOS.w * GetOddNegativeScale();
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
    #endif

    output.normalWS = normalInput.normalWS;

    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    output.tangentWS = tangentWS;
    #endif

#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS = GetViewDirectionTangentSpace(tangentWS, output.normalWS, viewDirWS);
    output.viewDirTS = viewDirTS;
#endif

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
#ifdef DYNAMICLIGHTMAP_ON
    output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
#ifdef USE_APV_PROBE_OCCLUSION
    output.probeOcclusion = GetProbeOcclusionData(vertexInput.positionWS);
#endif

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
#else
    output.fogFactor = fogFactor;
#endif

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    output.positionWS = vertexInput.positionWS;
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    output.shadowCoord = GetShadowCoord(vertexInput);
#endif

    output.positionCS = vertexInput.positionCS;

    return output;
}

// Split lighting calculation for SSS with transmission support
// Based on HDRP's approach: separate diffR (reflection) and diffT (transmission)
void LightingPhysicallyBasedSplit(BRDFData brdfData, BRDFData brdfDataClearCoat,
    half3 lightColor, half3 lightDirectionWS, float lightAttenuation,
    half3 normalWS, half3 viewDirectionWS,
    half clearCoatMask, bool specularHighlightsOff, half3 transmittance,
    uint diffusionProfileIndex, out half3 diffuse, out half3 specular)
{
    half NdotL = dot(normalWS, lightDirectionWS);
    half clampedNdotL = saturate(NdotL);
    
    // Following HDRP exactly: compute wrapped NdotL for transmission (back-lighting)
    // TRANSMISSION_WRAP_ANGLE = PI/12 (15 degrees)
    // TRANSMISSION_WRAP_LIGHT = cos(PI/2 - PI/12) = cos(5*PI/12) ≈ 0.2588
    #define TRANSMISSION_WRAP_LIGHT 0.2588190451025207701
    half flippedNdotL = ComputeWrappedDiffuseLighting(-NdotL, TRANSMISSION_WRAP_LIGHT);
    
    half3 radianceR = lightColor * (lightAttenuation * clampedNdotL);
    half3 radianceT = lightColor * (lightAttenuation * flippedNdotL);
    
    // Apply Diffuse Power modification (following HDRP FillMaterialAdvancedSSS)
    // Ref: HDRP Lit.hlsl EvaluateBSDF() line 1504-1509
    half diffuseNdotL = clampedNdotL;
    float diffusePower = GetDiffusePower(diffusionProfileIndex);
    if (diffusePower != 0.0)
    {
        diffuseNdotL = pow(diffuseNdotL, max(diffusePower + 1, 1.0));
        diffuseNdotL *= diffusePower * 0.5 + 1; // normalize
    }

    // Diffuse lighting split into reflection (diffR) and transmission (diffT)
    // Following HDRP formula: diffuse = (diffR + diffT * transmittance) * lightColor
    // Apply diffuseNdotL (with power modification) instead of clampedNdotL
    half3 diffR = brdfData.diffuse * lightColor * (lightAttenuation * diffuseNdotL);
    half3 diffT = brdfData.diffuse * radianceT * transmittance;
    diffuse = diffR + diffT;
    
    // Specular lighting
    specular = half3(0, 0, 0);
#ifndef _SPECULARHIGHLIGHTS_OFF
    [branch] if (!specularHighlightsOff)
    {
        specular = brdfData.specular * DirectBRDFSpecular(brdfData, normalWS, lightDirectionWS, viewDirectionWS) * radianceR;

#if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
        // Clear coat evaluates the specular a second time and has some common terms with the base specular.
        // We rely on the compiler to merge these and compute them only once.
        half brdfCoat = kDielectricSpec.r * DirectBRDFSpecular(brdfDataClearCoat, normalWS, lightDirectionWS, viewDirectionWS);

        // Mix clear coat and base layer using khronos glTF recommended formula
        // https://github.com/KhronosGroup/glTF/blob/master/extensions/2.0/Khronos/KHR_materials_clearcoat/README.md
        // Use NoV for direct too instead of LoH as an optimization (NoV is light invariant).
        half NoV = saturate(dot(normalWS, viewDirectionWS));
        // Use slightly simpler fresnelTerm (Pow4 vs Pow5) as a small optimization.
        // It is matching fresnel used in the GI/Env, so should produce a consistent clear coat blend (env vs. direct)
        half coatFresnel = kDielectricSpec.x + kDielectricSpec.a * Pow4(1.0 - NoV);

        specular = specular * (1.0 - clearCoatMask * coatFresnel) + brdfCoat * clearCoatMask * radianceR;
#endif // _CLEARCOAT
    }
#endif // _SPECULARHIGHLIGHTS_OFF
}

void LightingPhysicallyBasedSplit(BRDFData brdfData, BRDFData brdfDataClearCoat, Light light,
    half3 normalWS, half3 viewDirectionWS, half clearCoatMask, bool specularHighlightsOff,
    half3 transmittance, uint diffusionProfileIndex, out half3 diffuse, out half3 specular)
{
    LightingPhysicallyBasedSplit(brdfData, brdfDataClearCoat,
        light.color, light.direction, light.distanceAttenuation * light.shadowAttenuation,
        normalWS, viewDirectionWS, clearCoatMask, specularHighlightsOff, transmittance,
        diffusionProfileIndex, diffuse, specular);
}

// Used in Standard (Physically Based) shader with split lighting output
void SSSBufferFragment(
    Varyings input
    , out half4 outSpecular : SV_Target0      // Specular lighting (no SSS blur)
    , out half4 outDiffuse : SV_Target1       // Diffuse lighting (for SSS blur)
    , out SSSBufferType outSSSBuffer : SV_Target2  // SSS material data (diffusion profile, thickness, etc.)
#ifdef _WRITE_RENDERING_LAYERS
    , out uint outRenderingLayers : SV_Target3
#endif
)
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

#if defined(_PARALLAXMAP)
#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS = input.viewDirTS;
#else
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, viewDirWS);
#endif
    ApplyPerPixelDisplacement(viewDirTS, input.uv);
#endif

    SurfaceData surfaceData;
    InitializeStandardLitSurfaceData(input.uv, surfaceData);

    half subsurfaceMask = SampleSubsurfaceMask(input.uv);
    half transmissionMask = SampleTransmissionMask(input.uv);

#ifdef LOD_FADE_CROSSFADE
    LODFadeCrossFade(input.positionCS);
#endif

    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);
    #if UNITY_VERSION >= 60000000
        SETUP_DEBUG_TEXTURE_DATA(inputData, UNDO_TRANSFORM_TEX(input.uv, _BaseMap));
    #else
        SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);
    #endif
    

#if defined(_DBUFFER)
    ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
#endif

    InitializeBakedGIData(input, inputData);

    // Calculate split lighting
    #if defined(_SPECULARHIGHLIGHTS_OFF)
    bool specularHighlightsOff = true;
    #else
    bool specularHighlightsOff = false;
    #endif

    // Get diffusion profile index first
    uint diffusionProfileIndex = GetDiffusionProfileIndex(_DiffusionProfileHash);
    
    // Initialize BRDF data with SSS-specific handling (overrides f0 from diffusion profile)
    // This also applies SSS texturing mode to modify diffuse color (following HDRP FillMaterialSSS)
    BRDFData brdfData;
    InitializeBRDFDataSSS(surfaceData, diffusionProfileIndex, subsurfaceMask, brdfData);

    #if defined(DEBUG_DISPLAY)
    half4 debugColor;
    if (CanDebugOverrideOutputColor(inputData, surfaceData, brdfData, debugColor))
    {
        outSpecular = debugColor;
        outDiffuse = half4(0, 0, 0, 1.0);
        
        // Still need to output valid SSS buffer in debug mode
        SSSData sssData;
        sssData.diffuseColor = brdfData.diffuse;
        sssData.subsurfaceMask = subsurfaceMask;
        sssData.diffusionProfileIndex = GetDiffusionProfileIndex(_DiffusionProfileHash);
        ENCODE_INTO_SSSBUFFER(surfaceData, input.positionCS.xy, sssData, outSSSBuffer);
        
        return;
    }
    #endif

    // Clear-coat calculation...
    BRDFData brdfDataClearCoat = CreateClearCoatBRDFData(surfaceData, brdfData);
    half4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
    uint meshRenderingLayers = GetMeshRenderingLayer();
    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);

    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

    // Calculate transmittance for SSS (following HDRP approach)
    // Ref: HDRP FillMaterialTransmission() in SubsurfaceScattering.hlsl
    float2 thicknessRemap = _WorldScalesAndFilterRadiiAndThicknessRemaps[diffusionProfileIndex].zw;
    
    float thickness = SampleThickness(input.uv);
    thickness = thicknessRemap.x + thicknessRemap.y * thickness;
    
    // Compute transmittance using baked thickness here. It may be overridden for direct lighting
    // in the auto-thickness mode (but is always used for indirect lighting).
    half3 transmittance = ComputeTransmittanceDisney(_ShapeParamsAndMaxScatterDists[diffusionProfileIndex].rgb,
                                                     _TransmissionTintsAndFresnel0[diffusionProfileIndex].rgb,
                                                     thickness) * transmissionMask;

    // Split lighting following HDRP naming convention
    // diffuseLighting = direct diffuse + indirect diffuse + emission
    // specularLighting = direct specular + indirect specular
    half3 diffuseLighting = 0;
    half3 specularLighting = 0;

    // GI - Split into indirect diffuse and indirect specular
    half3 reflectVector = reflect(-inputData.viewDirectionWS, inputData.normalWS);
    half NoV = saturate(dot(inputData.normalWS, inputData.viewDirectionWS));
    // Use simplified fresnel term for environment BRDF (URP standard approach)
    // The actual f0 value is already correctly set in brdfData.specular from diffusion profile
    half fresnelTerm = Pow4(1.0 - NoV);
    
    // Indirect diffuse (from baked GI / light probes)
    half3 indirectDiffuse = inputData.bakedGI * aoFactor.indirectAmbientOcclusion;
    diffuseLighting += indirectDiffuse * brdfData.diffuse;
    
    // Indirect specular (environment reflection)
    half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, inputData.positionWS, 
                                                         brdfData.perceptualRoughness, 1.0h, 
                                                         inputData.normalizedScreenSpaceUV);
    specularLighting += indirectSpecular * EnvironmentBRDFSpecular(brdfData, fresnelTerm);
    
#if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    // Clear coat indirect specular
    half3 coatIndirectSpecular = GlossyEnvironmentReflection(reflectVector, inputData.positionWS, 
                                                             brdfDataClearCoat.perceptualRoughness, 1.0h,
                                                             inputData.normalizedScreenSpaceUV);
    half coatFresnel = kDielectricSpec.x + kDielectricSpec.a * Pow4(1.0 - NoV);
    specularLighting = specularLighting * (1.0 - surfaceData.clearCoatMask * coatFresnel) + 
                       coatIndirectSpecular * EnvironmentBRDFSpecular(brdfDataClearCoat, fresnelTerm) * surfaceData.clearCoatMask;
#endif

    // Main light - Direct lighting
    half3 mainDiffuse, mainSpecular;
#ifdef _LIGHT_LAYERS
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
#endif
    {
        LightingPhysicallyBasedSplit(brdfData, brdfDataClearCoat, mainLight,
                                     inputData.normalWS, inputData.viewDirectionWS,
                                     surfaceData.clearCoatMask, specularHighlightsOff,
                                     transmittance, diffusionProfileIndex,
                                     mainDiffuse, mainSpecular);
        diffuseLighting += mainDiffuse;
        specularLighting += mainSpecular;
    }

    // Additional lights
    #if defined(_ADDITIONAL_LIGHTS)
    uint pixelLightCount = GetAdditionalLightsCount();

    #if USE_CLUSTER_LIGHT_LOOP
    [loop] for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
    {
        CLUSTER_LIGHT_LOOP_SUBTRACTIVE_LIGHT_CHECK

        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

#ifdef _LIGHT_LAYERS
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
#endif
        {
            half3 addDiffuse, addSpecular;
            LightingPhysicallyBasedSplit(brdfData, brdfDataClearCoat, light,
                                         inputData.normalWS, inputData.viewDirectionWS,
                                         surfaceData.clearCoatMask, specularHighlightsOff,
                                         transmittance, diffusionProfileIndex,
                                         addDiffuse, addSpecular);
            diffuseLighting += addDiffuse;
            specularLighting += addSpecular;
        }
    }
    #endif

    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

#ifdef _LIGHT_LAYERS
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
#endif
        {
            half3 addDiffuse, addSpecular;
            LightingPhysicallyBasedSplit(brdfData, brdfDataClearCoat, light,
                                         inputData.normalWS, inputData.viewDirectionWS,
                                         surfaceData.clearCoatMask, specularHighlightsOff,
                                         transmittance, diffusionProfileIndex,
                                         addDiffuse, addSpecular);
            diffuseLighting += addDiffuse;
            specularLighting += addSpecular;
        }
    LIGHT_LOOP_END
    #endif

    // Vertex lighting (direct diffuse only)
    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    diffuseLighting += inputData.vertexLighting * brdfData.diffuse;
    #endif

    // Emission - Following HDRP, emissive is part of diffuse lighting
    diffuseLighting += surfaceData.emission;

    // Output split lighting following HDRP convention
    // Apply fog to specular output
    specularLighting = MixFog(specularLighting, inputData.fogCoord);
    
    outSpecular = half4(specularLighting, OutputAlpha(surfaceData.alpha, IsSurfaceTypeTransparent(_Surface)));
    outDiffuse = half4(TagLightingForSSS(diffuseLighting), 1.0);

    // Encode SSS Buffer (Target2) - Following HDRP convention
    // This buffer contains material information needed for the SSS blur pass
    // Note: thickness is NOT stored in SSS Buffer, it's read from thickness map during blur pass
    SSSData sssData;
    sssData.diffuseColor = brdfData.diffuse;
    sssData.subsurfaceMask = subsurfaceMask;
    sssData.diffusionProfileIndex = GetDiffusionProfileIndex(_DiffusionProfileHash);
    
    // Encode into SSS Buffer
    ENCODE_INTO_SSSBUFFER(surfaceData, input.positionCS.xy, sssData, outSSSBuffer);

#ifdef _WRITE_RENDERING_LAYERS
    outRenderingLayers = EncodeMeshRenderingLayer();
#endif
}

#endif
