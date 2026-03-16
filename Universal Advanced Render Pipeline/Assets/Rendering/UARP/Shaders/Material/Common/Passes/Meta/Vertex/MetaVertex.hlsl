#ifndef URPPLUS_META_VERTEX_INCLUDED
#define URPPLUS_META_VERTEX_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Meta/MetaInput.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/VertexDisplacement.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Meta/Varyings.hlsl"
#if defined(UNITY_DOTS_INSTANCING_ENABLED)
#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/ComputeDOTSDeformation.hlsl"
#endif

Varyings VertexMeta(Attributes input)
{
    Varyings output = (Varyings)0;

    output.uv = TRANSFORM_TEX(input.uv0, _BaseMap);

    #if defined(UNITY_DOTS_INSTANCING_ENABLED) && defined(_COMPUTE_DOTS_DEFORMATION)
    ComDefoputermedVertex(input.vertexId, input.positionOS.xyz, input.normalOS.xyz, input.tangentOS.xyzw);
    #endif
    real3 normalWS = TransformObjectToWorldNormal(input.normalOS);
    real3 positionWS = ApplyVertexDisplacementWS(input.positionOS.xyz, normalWS, output.uv);
    input.positionOS = mul(unity_WorldToObject, half4(positionWS, 1.0));

    output.positionCS = UnityMetaVertexPosition(input.positionOS.xyz, input.uv1, input.uv2);

    #ifdef EDITOR_VISUALIZATION
    UnityEditorVizData(input.positionOS.xyz, input.uv0, input.uv1, input.uv2, output.VizUV, output.LightCoord);
    #endif
    
    return output;
}

#endif