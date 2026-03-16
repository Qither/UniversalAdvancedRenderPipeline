#ifndef URPPLUS_DEPTH_NORMALS_FRAGMENT_INCLUDED
#define URPPLUS_DEPTH_NORMALS_FRAGMENT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#if defined(LOD_FADE_CROSSFADE)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthNormals/DepthNormalsVaryings.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/PerPixelDisplacement.hlsl"

void DepthNormalsFragment(
    Varyings input
    , half faceSign : VFACE
    , out half4 outNormalWS : SV_Target0
    #ifdef _WRITE_RENDERING_LAYERS
    , out float4 outRenderingLayers : SV_Target1
    #endif
    #if defined(_PIXEL_DISPLACEMENT) && defined(_DEPTHOFFSET_ON)
    , out float outputDepth : SV_Depth
    #endif
)
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    half2 alphaRemap = half2(_AlphaRemapMin, _AlphaRemapMax);
    half albedoAlpha = SampleAlbedoAlpha(_BaseColor, alphaRemap, input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a;
    Alpha(albedoAlpha, _AlphaCutoff);

    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(input.positionCS);
    #endif

    #if defined(_GBUFFER_NORMALS_OCT)
        float3 normalWS = normalize(input.normalWS);
        float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms
        float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
        half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
        outNormalWS = half4(packedNormalWS, 0.0);
    #else
        float3 normalWS = input.normalWS;

        #ifdef _PIXEL_DISPLACEMENT
            half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
            half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, viewDirWS);
    
            float depthOffset = ApplyPerPixelDisplacement(viewDirTS, viewDirWS, input.positionWS, input.uv);
            
            #ifdef _DEPTHOFFSET_ON
                outputDepth = depthOffset;
            #endif
        #endif

        normalWS = ApplyNormals(input, input.uv, faceSign);

        outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
    #endif

    #ifdef _WRITE_RENDERING_LAYERS
        uint renderingLayers = GetMeshRenderingLayer();
        outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
    #endif
}

#endif