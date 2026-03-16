#ifndef URPPLUS_DEFERRED_HAIR_FRAGMENT_INCLUDED
#define URPPLUS_DEFERRED_HAIR_FRAGMENT_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Hair/HairLighting.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Varyings/Attributes.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Varyings/DeferredVaryings.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Fragment/Deferred/GBuffer.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/GlobalIllumination/BakedGI.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Data/InitializeDeferredInputData.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Data/InitializeVectorsData.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif

FragmentOutput HairGBufferPassFragment(Varyings input, half faceSign : VFACE)
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    SurfaceData surfaceData;
    HairData hairData;
    InitializeSurfaceData(input.uv, surfaceData, hairData);

    #ifdef _DOUBLESIDED_ON
        ApplyDoubleSidedFlipOrMirror(faceSign, _DoubleSidedConstants.xyz, surfaceData.normalTS);
    #endif

    #ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
        GeometricAAFiltering(input.normalWS.xyz, surfaceData.smoothness);
    #endif

    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(input.positionCS);
    #endif

    InputData inputData;
    InitializeDeferredInputData(input, surfaceData.normalTS, inputData);

    VectorsData vData;
    InitializeVectorsData(input, surfaceData, inputData, vData);

    SETUP_DEBUG_TEXTURE_DATA(inputData, UNDO_TRANSFORM_TEX(input.uv, _BaseMap));

    #ifdef _DBUFFER
        ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
    #endif

    InitializeBakedGIData(input, inputData);

    // Stripped down version of UniversalFragmentPBR().

    // in LitForwardPass GlobalIllumination (and temporarily LightingPhysicallyBased) are called inside UniversalFragmentPBR
    // in Deferred rendering we store the sum of these values (and of emission as well) in the GBuffer
    BRDFData brdfData;
    InitializeSpecularBRDFData(inputData, surfaceData, brdfData);

    Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);

    half3 indirectSpecular, coatIndirectSpecular;
    ComputeIndirectSpecular(vData, inputData.positionWS, inputData.normalizedScreenSpaceUV, 
                            brdfData.perceptualRoughness, 0.0, surfaceData.anisotropy, 
                            indirectSpecular, coatIndirectSpecular);
                            
    half3 color = ComplexGlobalIllumination(surfaceData, brdfData, vData, inputData.bakedGI, indirectSpecular,
                                                coatIndirectSpecular, surfaceData.occlusion);
    
    return BRDFDataToGbuffer(brdfData, inputData, surfaceData.smoothness, surfaceData.emission + color,
                             surfaceData.occlusion);
}

#endif