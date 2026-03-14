#ifndef URP_SSS_TRANSMISSION_INCLUDED
#define URP_SSS_TRANSMISSION_INCLUDED

float3 EvaluateTransmission(float3 diffuseColor, float3 transmissionTint, float transmissionMask, float transmissionBoost)
{
    return diffuseColor * transmissionTint * transmissionMask * transmissionBoost;
}

#endif
