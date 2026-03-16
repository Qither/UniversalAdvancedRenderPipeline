#ifndef URPPLUS_SHADOW_CASTER_TESSELLATION_VERTEX_INCLUDED
#define URPPLUS_SHADOW_CASTER_TESSELLATION_VERTEX_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/ShadowCaster/Varyings.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/VertexDisplacement.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/Tessellation/Tessellation.hlsl"
#if defined(UNITY_DOTS_INSTANCING_ENABLED)
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/ComputeDOTSDeformation.hlsl"
#endif

float4 GetShadowPositionHClip(Attributes input, real2 uv)
{
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
    float3 positionWS = ApplyVertexDisplacementWS(input.positionOS.xyz, normalWS, uv);

    #if _CASTING_PUNCTUAL_LIGHT_SHADOW
        float3 lightDirectionWS = normalize(_LightPosition - positionWS);
    #else
        float3 lightDirectionWS = _LightDirection;
    #endif

    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
    positionCS = ApplyShadowClamping(positionCS);
    return positionCS;
}

TessellationControlPoint ShadowPassVertex(Attributes input)
{
    TessellationControlPoint output = (TessellationControlPoint)0;
    UNITY_SETUP_INSTANCE_ID(input);

    output.texcoord = input.texcoord;
    output.normalOS = input.normalOS;
    output.positionOS = input.positionOS;
    
    return output;
}

[domain("tri")]
Varyings ShadowDomain(TessellationFactors tessFactors, const OutputPatch<TessellationControlPoint, 3> input, float3 baryCoords : SV_DomainLocation)
{
    Varyings output = (Varyings)0;
    Attributes data = (Attributes)0;

    UNITY_SETUP_INSTANCE_ID(input[0]);

    data.positionOS = BARYCENTRIC_INTERPOLATE(positionOS); 
    data.normalOS = BARYCENTRIC_INTERPOLATE(normalOS);
    data.texcoord = BARYCENTRIC_INTERPOLATE(texcoord);

    #if defined(_TESSELLATION_PHONG)
        float3 p0 = TransformObjectToWorld(input[0].positionOS.xyz);
        float3 p1 = TransformObjectToWorld(input[1].positionOS.xyz);
        float3 p2 = TransformObjectToWorld(input[2].positionOS.xyz);

        float3 n0 = TransformObjectToWorldNormal(input[0].normalOS);
        float3 n1 = TransformObjectToWorldNormal(input[1].normalOS);
        float3 n2 = TransformObjectToWorldNormal(input[2].normalOS);
        float3 positionPredisplacementWS = TransformObjectToWorld(data.positionOS.xyz);

        positionPredisplacementWS = PhongTessellation(positionPredisplacementWS, p0, p1, p2, n0, n1, n2, baryCoords, _TessellationShapeFactor);
        data.positionOS = mul(unity_WorldToObject, float4(positionPredisplacementWS, 1.0));
    #endif

    output.uv = TRANSFORM_TEX(data.texcoord, _BaseMap);
    #if defined(UNITY_DOTS_INSTANCING_ENABLED) && defined(_COMPUTE_DOTS_DEFORMATION)
    ComputeDeformedVertex(data.vertexId, input.positionOS.xyz, input.normalOS.xyz, input.tangentOS.xyzw);
    #endif
    
    output.positionCS = GetShadowPositionHClip(data, output.uv);

    return output;
}

#endif