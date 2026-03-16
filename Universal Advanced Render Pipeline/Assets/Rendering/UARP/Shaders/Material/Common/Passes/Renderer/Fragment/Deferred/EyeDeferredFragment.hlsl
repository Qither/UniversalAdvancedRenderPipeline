#ifndef URPPLUS_DEFERRED_EYE_FRAGMENT_INCLUDED
#define URPPLUS_DEFERRED_EYE_FRAGMENT_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Eye/EyeLighting.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Varyings/Attributes.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Varyings/DeferredVaryings.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Fragment/Deferred/GBuffer.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/GlobalIllumination/BakedGI.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Data/InitializeDeferredInputData.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Data/InitializeVectorsData.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif

inline void TransformEyeVectorsToOS(Varyings input, inout float3 positionOS, inout float3 viewDirOS, inout float3 normalOS)
{
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    positionOS = (TransformWorldToObject(input.positionWS)) * _MeshScale;
    viewDirOS = TransformWorldToObjectDir(viewDirWS);
    normalOS = TransformWorldToObjectDir(normalize(input.normalWS));
}

// Used in Standard (Physically Based) shader
FragmentOutput EyeGBufferPassFragment(Varyings input, half faceSign : VFACE)
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float3 positionOS, viewDirOS, normalOS;
    TransformEyeVectorsToOS(input, positionOS, viewDirOS, normalOS);
    
    float3 refractedPosOS = CorneaRefraction(positionOS + float3(0.0, 0.0, _PositionOffset.z), viewDirOS, normalOS, 1.333h, 0.02h) + _PositionOffset.xyz;
    float2 irisUV = IrisUVLocation(refractedPosOS, 0.225h);
    float2 scleraUV = ScleraUVLocation(positionOS);
    
    half scleraLimbalRing = ScleraLimbalRing(positionOS, viewDirOS, 0.225h, _LimbalRingSizeSclera, _LimbalRingFade, _LimbalRingIntensity);

    half surfaceMask = CalculateSurfaceMask(positionOS);
    half mydriasisK = 1.0;

    float2 circlePupilAnim = CirclePupilAnimation(irisUV, _PupilRadius, saturate(mydriasisK * _PupilAperture), _MinimalPupilAperture, _MaximalPupilAperture);
    float2 irisOffset = circlePupilAnim;

    half3 irisAlbedo = SAMPLE_TEXTURE2D(_IrisMap, sampler_IrisMap, irisOffset).rgb;
    half3 scleraAlbedo = SAMPLE_TEXTURE2D(_ScleraMap, sampler_ScleraMap, scleraUV).rgb * scleraLimbalRing;

    half irisLimbalRing = IrisLimbalRing(irisUV, viewDirOS, _LimbalRingSizeIris, _LimbalRingFade, _LimbalRingIntensity);
    half3 irisColor = IrisOutOfBoundColorClamp(irisOffset, irisAlbedo, _IrisClampColor.rgb) * irisLimbalRing;

    half3 irisNormal = SampleEyeNormal(irisOffset, TEXTURE2D_ARGS(_IrisNormalMap, SAMPLER_NORMALMAP_IDX), _IrisNormalScale);
    half3 scleraNormal = SampleEyeNormal(scleraUV, TEXTURE2D_ARGS(_ScleraNormalMap, SAMPLER_NORMALMAP_IDX), _ScleraNormalScale);

    half3 diffuseNormalTS = lerp(scleraNormal, irisNormal, surfaceMask);
    half3 specularNormalTS = lerp(scleraNormal, half3(0.0, 0.0, 1.0), surfaceMask);

    half3 surfaceNormal = NormalizeNormalPerPixel(input.normalWS);
    half3 diffuseNormalWS = surfaceNormal;
    half3 specularNormalWS = surfaceNormal;
    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
        float sgn = input.tangentWS.w; // should be either +1 or -1
        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

        #if defined(_IRIS_NORMALMAP) || (_DOUBLESIDED_ON)
            diffuseNormalWS = NormalizeNormalPerPixel(TransformTangentToWorld(diffuseNormalTS, tangentToWorld));
        #endif

        #if defined(_SCLERA_NORMALMAP) || (_DOUBLESIDED_ON)
            specularNormalWS = NormalizeNormalPerPixel(TransformTangentToWorld(specularNormalTS, tangentToWorld));
        #endif
    #endif

    SurfaceData surfaceData;
    InitializeSurfaceData(input.uv, surfaceData);
    
    surfaceData.albedo = lerp(scleraAlbedo, irisColor, surfaceMask);
    surfaceData.smoothness = lerp(_ScleraSmoothness, _CorneaSmoothness, surfaceMask);
    surfaceData.emission = SampleEmission(irisOffset, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap), 
                                            surfaceData.albedo, _EmissionColor.rgb, _EmissionScale * surfaceMask);

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

    // in LitForwardPass GlobalIllumination (and temporarily LightingPhysicallyBased) are called inside UniversalFragmentPBR
    // in Deferred rendering we store the sum of these values (and of emission as well) in the GBuffer
    BRDFData brdfData;
    InitializeBRDFData(inputData, surfaceData, brdfData);

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
