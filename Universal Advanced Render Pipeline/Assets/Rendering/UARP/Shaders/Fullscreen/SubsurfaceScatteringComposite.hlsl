#ifndef URP_SSS_COMPOSITE_CORE_INCLUDED
#define URP_SSS_COMPOSITE_CORE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D_X(_BlitTexture);
SAMPLER(sampler_BlitTexture);
TEXTURE2D_X(_SSSDiffuseTex);
SAMPLER(sampler_SSSDiffuseTex);
TEXTURE2D_X(_SSSBlurredTex);
SAMPLER(sampler_SSSBlurredTex);

struct FullscreenAttributes
{
    uint vertexID : SV_VertexID;
};

struct FullscreenVaryings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
};

FullscreenVaryings FullscreenVert(FullscreenAttributes input)
{
    FullscreenVaryings output;
    output.uv = GetFullScreenTriangleTexCoord(input.vertexID);
    output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
    return output;
}

half4 SSSCompositeFragment(FullscreenVaryings input) : SV_Target
{
    half4 scene = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, input.uv);
    half4 rawDiffuse = SAMPLE_TEXTURE2D_X(_SSSDiffuseTex, sampler_SSSDiffuseTex, input.uv);
    half4 blurred = SAMPLE_TEXTURE2D_X(_SSSBlurredTex, sampler_SSSBlurredTex, input.uv);
    return half4(scene.rgb - rawDiffuse.rgb + blurred.rgb, scene.a);
}

#endif
