#ifndef URP_LIT_SSS_INPUT_INCLUDED
#define URP_LIT_SSS_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
float4 _BaseColorMap_ST;
half4 _BaseColor;
half _NormalScale;
half _SubsurfaceMask;
half _TransmissionMask;
half _Thickness;
half _TransmissionEnable;
half _DiffusionProfileIndex;
float4 _ThicknessRemap;
float4 _DiffusionProfileAsset;
half _DiffusionProfileHash;
CBUFFER_END

TEXTURE2D(_BaseColorMap);
SAMPLER(sampler_BaseColorMap);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_SubsurfaceMaskMap);
SAMPLER(sampler_SubsurfaceMaskMap);
TEXTURE2D(_ThicknessMap);
SAMPLER(sampler_ThicknessMap);
TEXTURE2D(_TransmissionMaskMap);
SAMPLER(sampler_TransmissionMaskMap);

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
};

Varyings LitVertex(Attributes input)
{
    Varyings output;
    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
    output.positionCS = positionInputs.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseColorMap);
    output.normalWS = NormalizeNormalPerVertex(normalInputs.normalWS);
    return output;
}

half4 SampleBase(float2 uv)
{
    return SAMPLE_TEXTURE2D(_BaseColorMap, sampler_BaseColorMap, uv) * _BaseColor;
}

half SampleSubsurfaceMask(float2 uv)
{
    return SAMPLE_TEXTURE2D(_SubsurfaceMaskMap, sampler_SubsurfaceMaskMap, uv).r * _SubsurfaceMask;
}

half SampleThickness(float2 uv)
{
    half thickness = SAMPLE_TEXTURE2D(_ThicknessMap, sampler_ThicknessMap, uv).r;
    return lerp(_ThicknessRemap.x, _ThicknessRemap.y, thickness) * _Thickness;
}

half SampleTransmissionMask(float2 uv)
{
    return SAMPLE_TEXTURE2D(_TransmissionMaskMap, sampler_TransmissionMaskMap, uv).r * _TransmissionMask;
}

#endif
