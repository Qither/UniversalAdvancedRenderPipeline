#ifndef URPPLUS_DISPLACEMENT_UTILS_INCLUDED
#define URPPLUS_DISPLACEMENT_UTILS_INCLUDED

float3 GetDisplacementObjectScale(bool vertexDisplacement)
{
    float3 objectScale = float3(1.0, 1.0, 1.0);
    float4x4 worldTransform;

    if (vertexDisplacement)
    {
        worldTransform = GetObjectToWorldMatrix();
    }
    else
    {
        worldTransform = GetWorldToObjectMatrix();
    }

    objectScale.x = length(float3(worldTransform._m00, worldTransform._m01, worldTransform._m02));
    #if !defined(_PIXEL_DISPLACEMENT) || (defined(_PIXEL_DISPLACEMENT_LOCK_OBJECT_SCALE))
        objectScale.y = length(float3(worldTransform._m10, worldTransform._m11, worldTransform._m12));
    #endif
    objectScale.z = length(float3(worldTransform._m20, worldTransform._m21, worldTransform._m22));

    return objectScale;
}

float GetMaxDisplacement()
{
    float maxDisplacement = 0.0;
    #if defined(_HEIGHTMAP)
    maxDisplacement = abs(_HeightAmplitude); // _HeightAmplitude can be negative if min and max are inverted, but the max displacement must be positive
    #endif

    return maxDisplacement;
}

float2 GetMinUvSize(float2 uv)
{
    float2 minUvSize = float2(FLT_MAX, FLT_MAX);

    #if defined(_HEIGHTMAP)
    minUvSize = min(uv * _HeightMap_TexelSize.zw, minUvSize);
    #endif

    return minUvSize;
}

void ApplyDisplacementTileScale(inout float height)
{
    // Inverse tiling scale = 2 / (abs(_BaseColorMap_ST.x) + abs(_BaseColorMap_ST.y)
    // Inverse tiling scale *= (1 / _TexWorldScale) if planar or triplanar
    #ifdef _DISPLACEMENT_LOCK_TILING_SCALE
    height *= _InvTilingScale;
    #endif
}

float3 GetViewDirectionTangentSpace(float4 tangentWS, real3 normalWS, real3 viewDirWS)
{
    real3 unnormalizedNormalWS = normalWS;
    const half renormFactor = 1.0 / length(unnormalizedNormalWS);

    float crossSign = (tangentWS.w > 0.0 ? 1.0 : -1.0);
    real3 bitangent = crossSign * cross(normalWS.xyz, tangentWS.xyz);

    real3 WorldSpaceNormal = renormFactor * normalWS.xyz;
    real3 WorldSpaceTangent = renormFactor * tangentWS.xyz;
    real3 WorldSpaceBiTangent = renormFactor * bitangent;

    real3x3 tangentSpaceTransform = real3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal);
    half3 viewDirTS = mul(tangentSpaceTransform, viewDirWS);

    return viewDirTS;
}

#endif