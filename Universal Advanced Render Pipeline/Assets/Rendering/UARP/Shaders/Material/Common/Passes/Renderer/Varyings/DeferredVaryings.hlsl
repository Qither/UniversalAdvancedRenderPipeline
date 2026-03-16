#ifndef URPPLUS_DEFERRED_VARYINGS_INCLUDED
#define URPPLUS_DEFERRED_VARYINGS_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Lighting/LightingDefines.hlsl"

struct Varyings
{
    float2 uv : TEXCOORD0;

    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR) || defined(_PIXEL_DISPLACEMENT) || defined(_WEATHER_ON)
    float3 positionWS : TEXCOORD1;
    #endif

    half3 normalWS : TEXCOORD2;
    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    half4 tangentWS : TEXCOORD3; // xyz: tangent, w: sign
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
    half3 vertexLighting : TEXCOORD4;    // xyz: vertex lighting
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord : TEXCOORD5;
    #endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);
    #ifdef DYNAMICLIGHTMAP_ON
    float2  dynamicLightmapUV : TEXCOORD8; // Dynamic lightmap UVs
    #endif

    #ifdef USE_APV_PROBE_OCCLUSION
    float4 probeOcclusion           : TEXCOORD9;
    #endif

    float4 positionCS : SV_POSITION;
    
    #if defined(REQUIRE_VERTEX_COLOR)
    half4 vertexColor : COLOR;
    #endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

#endif