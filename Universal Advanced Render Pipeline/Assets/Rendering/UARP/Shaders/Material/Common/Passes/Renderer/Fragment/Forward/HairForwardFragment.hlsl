#ifndef URPPLUS_FORWARD_HAIR_FRAGMENT_INCLUDED
#define URPPLUS_FORWARD_HAIR_FRAGMENT_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Hair/HairLighting.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Varyings/Attributes.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Varyings/ForwardVaryings.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/GlobalIllumination/BakedGI.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Data/InitializeForwardInputData.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Data/InitializeVectorsData.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif

void HairPassFragment(
    Varyings input
    , half faceSign : VFACE
    , out half4 outColor : SV_Target0
    #ifdef _WRITE_RENDERING_LAYERS
    , out float4 outRenderingLayers : SV_Target1
    #endif
)
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
    InitializeForwardInputData(input, surfaceData.normalTS, inputData);

    VectorsData vData;
    InitializeVectorsData(input, surfaceData, inputData, vData);

    SETUP_DEBUG_TEXTURE_DATA(inputData, UNDO_TRANSFORM_TEX(input.uv, _BaseMap));

    #ifdef _DBUFFER
        ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
    #endif

    InitializeBakedGIData(input, inputData);

    half4 color = HairFragment(inputData, surfaceData, vData, hairData);
    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    color.a = OutputAlpha(color.a, IsSurfaceTypeTransparent(_Surface));

    outColor = color;

    #ifdef _WRITE_RENDERING_LAYERS
        uint renderingLayers = GetMeshRenderingLayer();
        outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
    #endif
}

#endif