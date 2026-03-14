#ifndef URP_LIT_SSS_DIFFUSE_INCLUDED
#define URP_LIT_SSS_DIFFUSE_INCLUDED

#include "LitInput.hlsl"

half4 LitDiffuseFragment(Varyings input) : SV_Target
{
    half4 baseSample = SampleBase(input.uv);
    return half4(baseSample.rgb * SampleSubsurfaceMask(input.uv), 1.0h);
}

#endif
