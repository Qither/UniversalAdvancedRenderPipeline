#ifndef URPPLUS_META_VARYINGS_INCLUDED
#define URPPLUS_META_VARYINGS_INCLUDED

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 uv0 : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    float2 uv2 : TEXCOORD2;
    #if defined(REQUIRE_VERTEX_COLOR)
    half4 vertexColor : COLOR;
    #endif
    #if defined(_COMPUTE_DOTS_DEFORMATION)
    uint vertexId : SV_VertexID;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    #if defined(REQUIRE_VERTEX_COLOR)
    half4 vertexColor : COLOR;
    #endif

    #ifdef EDITOR_VISUALIZATION
    float2 VizUV : TEXCOORD1;
    float4 LightCoord : TEXCOORD2;
    #endif
};

#endif