#ifndef URPPLUS_DEPTH_NORMALS_VARYINGS_INCLUDED
#define URPPLUS_DEPTH_NORMALS_VARYINGS_INCLUDED

#if defined(_NORMALMAP) || defined(_NORMALMAP1) || defined(_NORMALMAP2) || defined(_NORMALMAP3)
    #define _NORMAL
#endif

#if defined(_DETAIL_MAP) || defined(_DETAIL_MAP1) || defined(_DETAIL_MAP2) || defined(_DETAIL_MAP3)
    #define _DETAIL
#endif

#if defined(_NORMALMAP) || defined(_DETAIL) || defined(_THREADMAP) || defined(_DOUBLESIDED_ON) || defined(_PIXEL_DISPLACEMENT)
    #define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 texcoord : TEXCOORD0;
    
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

    float2 uv : TEXCOORD1;
    
    half3 normalWS : TEXCOORD2;

    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR) || defined(_PIXEL_DISPLACEMENT)
    float3 positionWS : TEXCOORD3;
    #endif

    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    half4 tangentWS : TEXCOORD4; // xyz: tangent, w: sign
    #endif

    half3 viewDirWS : TEXCOORD5;

    #if defined(REQUIRE_VERTEX_COLOR)
    half4 vertexColor : COLOR;
    #endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

#endif