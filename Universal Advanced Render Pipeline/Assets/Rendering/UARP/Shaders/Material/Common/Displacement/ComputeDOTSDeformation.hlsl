#ifndef URPPLUS_COMPUTE_DOTS_DEFORMATION_INCLUDED
#define URPPLUS_COMPUTE_DOTS_DEFORMATION_INCLUDED

#if defined(UNITY_DOTS_INSTANCING_ENABLED) && defined(_COMPUTE_DOTS_DEFORMATION)
struct DeformedVertexData
{
    float3 position;
    float3 normal;
    float3 tangent;
};
uniform StructuredBuffer<DeformedVertexData> _DeformedMeshData: register(t1);
#endif

void ComputeDeformedVertex(uint vertexId, inout float3 p, inout float3 n, inout float4 t)
{
    #if defined(UNITY_DOTS_INSTANCING_ENABLED) && defined(_COMPUTE_DOTS_DEFORMATION)
    const DeformedVertexData vertexData = _DeformedMeshData[asuint(_ComputeMeshIndex) + vertexId];
    p = vertexData.position;
    n = vertexData.normal;
    t.xyz = vertexData.tangent;
    #endif
}

#endif