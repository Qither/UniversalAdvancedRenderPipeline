#ifndef URP_SSS_RESOLVE_CORE_INCLUDED
#define URP_SSS_RESOLVE_CORE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "../Common/DiffusionProfileCommon.hlsl"
#include "../Common/SubsurfaceScatteringPacking.hlsl"

TEXTURE2D_X(_SSSMetadataTex);
SAMPLER(sampler_SSSMetadataTex);
TEXTURE2D_X(_SSSProfileIndexTex);
SAMPLER(sampler_SSSProfileIndexTex);
TEXTURE2D_X(_SSSDiffuseTex);
SAMPLER(sampler_SSSDiffuseTex);

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

half4 SSSResolveFragment(FullscreenVaryings input) : SV_Target
{
    half4 diffuse = SAMPLE_TEXTURE2D_X(_SSSDiffuseTex, sampler_SSSDiffuseTex, input.uv);
    SSSMetadataData metadata = UnpackSSSMetadata(SAMPLE_TEXTURE2D_X(_SSSMetadataTex, sampler_SSSMetadataTex, input.uv));
    int profileIndex = (int)round(SAMPLE_TEXTURE2D_X(_SSSProfileIndexTex, sampler_SSSProfileIndexTex, input.uv).r);
    SSSProfileData profile = LoadSSSProfile(profileIndex);
    half blurFactor = metadata.mask * metadata.strength * saturate(profile.filterRadius * 0.1);
    return half4(diffuse.rgb * max(0.25h, blurFactor), 1.0h);
}

#endif
