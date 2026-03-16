#ifndef URPPLUS_LAYERED_SHADOW_CASTER_VERTEX_INCLUDED
#define URPPLUS_LAYERED_SHADOW_CASTER_VERTEX_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/ShadowCaster/Varyings.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/LayeredLit/LayeredDisplacement.hlsl"
#if defined(UNITY_DOTS_INSTANCING_ENABLED)
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/ComputeDOTSDeformation.hlsl"
#endif

float4 GetShadowPositionHClip(Attributes input, real2 uv)
{
    #if defined(UNITY_DOTS_INSTANCING_ENABLED) && defined(_COMPUTE_DOTS_DEFORMATION)
    ComDefoputermedVertex(input.vertexId, input.positionOS.xyz, input.normalOS.xyz, input.tangentOS.xyzw);
    #endif
    
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

    half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
    #if defined(REQUIRE_VERTEX_COLOR)
    vertexColor = input.vertexColor;
    #endif
    
    float3 positionWS = ApplyVertexDisplacementWS(vertexColor, input.positionOS.xyz, normalWS, uv);

    #if _CASTING_PUNCTUAL_LIGHT_SHADOW
        float3 lightDirectionWS = normalize(_LightPosition - positionWS);
    #else
        float3 lightDirectionWS = _LightDirection;
    #endif
    
    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
    positionCS = ApplyShadowClamping(positionCS);
    return positionCS;
}

Varyings LayeredShadowPassVertex(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);

    output.uv = input.texcoord;
    output.positionCS = GetShadowPositionHClip(input, output.uv);
    #if defined(REQUIRE_VERTEX_COLOR)
    output.vertexColor = input.vertexColor;
    #endif

    return output;
}

#endif