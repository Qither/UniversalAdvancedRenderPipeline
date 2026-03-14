#ifndef URP_LIT_SSS_FORWARD_INCLUDED
#define URP_LIT_SSS_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "LitInput.hlsl"
#include "../Common/DiffusionProfileCommon.hlsl"
#include "../Common/Transmission.hlsl"

half4 LitForwardFragment(Varyings input) : SV_Target
{
    half4 baseSample = SampleBase(input.uv);
    half3 normalWS = normalize(input.normalWS);
    Light mainLight = GetMainLight();
    half ndotl = saturate(dot(normalWS, mainLight.direction));
    half3 diffuse = baseSample.rgb * (0.15h + ndotl * mainLight.color);

    int profileIndex = (int)round(_DiffusionProfileIndex);
    SSSProfileData profile = LoadSSSProfile(profileIndex);
    half transmissionMask = SampleTransmissionMask(input.uv);
    diffuse += EvaluateTransmission(baseSample.rgb, profile.transmissionTint, transmissionMask, _TransmissionEnable) * (1.0h - ndotl);
    return half4(diffuse, baseSample.a);
}

#endif
