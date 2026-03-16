#ifndef URPPLUS_SHADOW_CASTER_VARYINGS_INCLUDED
#define URPPLUS_SHADOW_CASTER_VARYINGS_INCLUDED

// Shadow Casting Light geometric parameters. These variables are used when applying the shadow Normal Bias and are set by UnityEngine.Rendering.Universal.ShadowUtils.SetupShadowCasterConstantBuffer in com.unity.render-pipelines.universal/Runtime/ShadowUtils.cs
// For Directional lights, _LightDirection is used when applying shadow Normal Bias.
// For Spot lights and Point lights, _LightPosition is used to compute the actual light direction because it is different at each shadow caster geometry vertex.
float3 _LightDirection;
float3 _LightPosition;

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
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
    float2 uv : TEXCOORD0;
    float4 positionCS : SV_POSITION;
    #if defined(REQUIRE_VERTEX_COLOR)
    half4 vertexColor : COLOR;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

#endif