#ifndef URP_SSS_PACKING_INCLUDED
#define URP_SSS_PACKING_INCLUDED

#include "SubsurfaceScatteringCommon.hlsl"

float4 PackSSSMetadata(SSSMetadataData data)
{
    return float4(data.mask, data.thickness, data.transmissionMask, data.strength);
}

SSSMetadataData UnpackSSSMetadata(float4 value)
{
    SSSMetadataData data;
    data.mask = value.x;
    data.thickness = value.y;
    data.transmissionMask = value.z;
    data.strength = value.w;
    return data;
}

#endif
