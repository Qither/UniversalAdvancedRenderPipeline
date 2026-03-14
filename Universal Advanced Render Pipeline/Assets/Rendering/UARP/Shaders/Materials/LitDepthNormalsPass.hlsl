#ifndef URP_LIT_SSS_DEPTH_NORMALS_INCLUDED
#define URP_LIT_SSS_DEPTH_NORMALS_INCLUDED

#include "LitInput.hlsl"

half4 LitDepthNormalsFragment(Varyings input) : SV_Target
{
    float3 packedNormal = normalize(input.normalWS) * 0.5 + 0.5;
    return half4(packedNormal, 1.0h);
}

#endif
