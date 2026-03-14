#ifndef URP_LIT_SSS_META_INCLUDED
#define URP_LIT_SSS_META_INCLUDED

#include "LitInput.hlsl"
#include "../Common/SubsurfaceScatteringPacking.hlsl"

struct MetaOutput
{
    half4 metadata : SV_Target0;
    half profileIndex : SV_Target1;
};

MetaOutput LitMetaFragment(Varyings input)
{
    MetaOutput output;
    SSSMetadataData data;
    data.mask = SampleSubsurfaceMask(input.uv);
    data.thickness = SampleThickness(input.uv);
    data.transmissionMask = SampleTransmissionMask(input.uv);
    data.strength = SampleSubsurfaceMask(input.uv);
    output.metadata = PackSSSMetadata(data);
    output.profileIndex = _DiffusionProfileIndex;
    return output;
}

#endif
