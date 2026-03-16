#ifndef URPPLUS_LAYERED_LIT_DEPTH_NORMALS_INCLUDED
#define URPPLUS_LAYERED_LIT_DEPTH_NORMALS_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthNormals/DepthNormalsVaryings.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/LayeredLit/LayeredLitUtils.hlsl"

void ApplyLayeredDetailNormal(LayerTexCoord layerTexCoord, LayeredData layeredData, half weights[_MAX_LAYER], inout half3 normalTS)
{
    #ifdef _DETAIL_MAP
        half4 detailMap0 = SAMPLE_TEXTURE2D(_DetailMap, SAMPLER_DETAILMAP_IDX, layerTexCoord.detailUV0);
        normalTS = ApplyDetailNormal(normalTS, detailMap0.ag, _DetailNormalScale, layeredData.maskMap0.b * weights[0]);
    #endif

    #ifdef _DETAIL_MAP1
        half4 detailMap1 = SAMPLE_TEXTURE2D(_DetailMap1, SAMPLER_DETAILMAP_IDX, layerTexCoord.detailUV1);
        normalTS = ApplyDetailNormal(normalTS, detailMap1.ag, _DetailNormalScale1, layeredData.maskMap1.b * weights[1]);
    #endif

    #ifdef _DETAIL_MAP2
        half4 detailMap2 = SAMPLE_TEXTURE2D(_DetailMap2, SAMPLER_DETAILMAP_IDX, layerTexCoord.detailUV2);
        normalTS = ApplyDetailNormal(normalTS, detailMap2.ag, _DetailNormalScale2, layeredData.maskMap2.b * weights[2]);
    #endif

    #ifdef _DETAIL_MAP3
        half4 detailMap3 = SAMPLE_TEXTURE2D(_DetailMap3, SAMPLER_DETAILMAP_IDX, layerTexCoord.detailUV3);
        normalTS = ApplyDetailNormal(normalTS, detailMap3.ag, _DetailNormalScale3, layeredData.maskMap3.b * weights[3]);
    #endif
}

float3 ApplyNormals(Varyings input, LayerTexCoord layerTexCoord, LayeredData layeredData, half4 blendMasks, half faceSign, half weights[_MAX_LAYER])
{
    #if defined(_NORMAL) || defined(_DETAIL)
        float sgn = input.tangentWS.w;      // should be either +1 or -1
        half3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);

        half3 normalTS = half3(0.0, 0.0, 1.0);

        #if defined(_MAIN_LAYER_INFLUENCE_MODE)
        float influenceMask = GetInfluenceMask(layerTexCoord, TEXTURE2D_ARGS(_LayerInfluenceMaskMap, sampler_LayerInfluenceMaskMap));

        if (influenceMask > 0.0f)
        {
            normalTS = ComputeMainNormalInfluence(influenceMask, layeredData.normalMap0, layeredData.normalMap1, layeredData.normalMap2, layeredData.normalMap3, blendMasks.a, weights);
        }
        else
        #endif
        {
            normalTS = BlendLayeredVector3(layeredData.normalMap0, layeredData.normalMap1, layeredData.normalMap2, layeredData.normalMap3, weights);
        }

        ApplyLayeredDetailNormal(layerTexCoord, layeredData, weights, normalTS);

        #ifdef _DOUBLESIDED_ON
            ApplyDoubleSidedFlipOrMirror(faceSign, _DoubleSidedConstants.xyz, normalTS);
        #endif

        return TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
    #else
        return input.normalWS;
    #endif
}

#endif