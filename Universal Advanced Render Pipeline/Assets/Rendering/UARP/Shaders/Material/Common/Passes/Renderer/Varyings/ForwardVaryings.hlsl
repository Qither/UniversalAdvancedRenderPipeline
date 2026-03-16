#ifndef URPPLUS_FORWARD_VARYINGS_INCLUDED
#define URPPLUS_FORWARD_VARYINGS_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Lighting/LightingDefines.hlsl"

struct Varyings
{
    float2 uv : TEXCOORD0;

    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR) || defined(_PIXEL_DISPLACEMENT) || defined(_MATERIAL_FEATURE_IRIDESCENCE) || defined(_WEATHER_ON)
    float3 positionWS : TEXCOORD1;
    #endif

    float3 normalWS : TEXCOORD2;
    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    half4 tangentWS : TEXCOORD3; // xyz: tangent, w: sign
    #endif
    float3 viewDirWS : TEXCOORD4;

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
    half4 fogFactorAndVertexLight : TEXCOORD5; // x: fogFactor, yzw: vertex light
    #else
    half fogFactor : TEXCOORD5;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord : TEXCOORD6;
    #endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
    #ifdef DYNAMICLIGHTMAP_ON
    float2  dynamicLightmapUV : TEXCOORD9; // Dynamic lightmap UVs
    #endif

    #ifdef USE_APV_PROBE_OCCLUSION
    float4 probeOcclusion : TEXCOORD10;
    #endif

    float4 positionCS : SV_POSITION;

    #if defined(REQUIRE_VERTEX_COLOR)
    half4 vertexColor : COLOR;
    #endif
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

#endif