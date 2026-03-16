#ifndef URPPLUS_LAYERED_DEPTH_ONLY_FRAGMENT_INCLUDED
#define URPPLUS_LAYERED_DEPTH_ONLY_FRAGMENT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthOnly/Varyings.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/LayeredLit/LayeredDisplacement.hlsl"

half LayeredDepthOnlyFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
    #if defined(REQUIRE_VERTEX_COLOR)
        vertexColor = input.vertexColor;
    #endif

    LayerTexCoord layerTexCoord;
    InitializeTexCoordinates(input.uv, layerTexCoord);
    LayeredData layeredData;
    InitializeLayeredData(layerTexCoord, layeredData);

    half weights[_MAX_LAYER];
    half4 blendMasks = GetBlendMask(layerTexCoord.layerMaskUV, TEXTURE2D_ARGS(_LayerMaskMap, sampler_LayerMaskMap), vertexColor);
    ComputeLayerWeights(layeredData, blendMasks, _HeightTransition, weights);

    half alphasBlend = BlendLayeredScalar(layeredData.baseColor0.a, layeredData.baseColor1.a, layeredData.baseColor2.a, layeredData.baseColor3.a, weights);
    Alpha(alphasBlend, _AlphaCutoff);

    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(input.positionCS);
    #endif

    return input.positionCS.z;
}

#endif