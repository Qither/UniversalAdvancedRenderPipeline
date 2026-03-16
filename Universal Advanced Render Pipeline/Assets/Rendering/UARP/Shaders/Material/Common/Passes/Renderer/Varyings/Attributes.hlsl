#ifndef URPPLUS_ATTRIBUTES_INCLUDED
#define URPPLUS_ATTRIBUTES_INCLUDED

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 texcoord : TEXCOORD0;
    float2 staticLightmapUV : TEXCOORD1;
    float2 dynamicLightmapUV : TEXCOORD2;
    #if defined(REQUIRE_VERTEX_COLOR)
    float4 vertexColor : COLOR;
    #endif
    #if defined(_COMPUTE_DOTS_DEFORMATION)
    uint vertexId : SV_VertexID;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

#endif