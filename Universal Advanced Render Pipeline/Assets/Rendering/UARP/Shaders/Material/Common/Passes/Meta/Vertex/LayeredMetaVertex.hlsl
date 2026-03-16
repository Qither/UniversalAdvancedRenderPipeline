#ifndef URPPLUS_LAYERED_META_VERTEX_INCLUDED
#define URPPLUS_LAYERED_META_VERTEX_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Meta/MetaInput.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/LayeredLit/LayeredDisplacement.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Meta/Varyings.hlsl"
#if defined(UNITY_DOTS_INSTANCING_ENABLED)
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/ComputeDOTSDeformation.hlsl"
#endif

Varyings LayeredLitVertexMeta(Attributes input)
{
    Varyings output = (Varyings)0;

    output.uv = input.uv0;
    
    half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
    #if defined(REQUIRE_VERTEX_COLOR)
        vertexColor = input.vertexColor;
        output.vertexColor = input.vertexColor;
    #endif

    #if defined(UNITY_DOTS_INSTANCING_ENABLED) && defined(_COMPUTE_DOTS_DEFORMATION)
    ComDefoputermedVertex(input.vertexId, input.positionOS.xyz, input.normalOS.xyz, input.tangentOS.xyzw);
    #endif
    real3 normalWS = TransformObjectToWorldNormal(input.normalOS);
    real3 positionWS = ApplyVertexDisplacementWS(vertexColor, input.positionOS.xyz, normalWS, output.uv);
    input.positionOS = mul(unity_WorldToObject, half4(positionWS, 1.0));

    output.positionCS = UnityMetaVertexPosition(input.positionOS.xyz, input.uv1, input.uv2);

    #ifdef EDITOR_VISUALIZATION
    UnityEditorVizData(input.positionOS.xyz, input.uv0, input.uv1, input.uv2, output.VizUV, output.LightCoord);
    #endif
    
    return output;
}

#endif