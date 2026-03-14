#ifndef URP_SSS_PROFILE_COMMON_INCLUDED
#define URP_SSS_PROFILE_COMMON_INCLUDED

float4 _SSSProfileData0[16];
float4 _SSSProfileData1[16];
float4 _SSSProfileData2[16];
float4 _SSSProfileData3[16];
float _SSSProfileCount;

struct SSSProfileData
{
    float3 shapeParam;
    float worldScale;
    float3 transmissionTint;
    float fresnel0;
    float2 thicknessRemap;
    float filterRadius;
    float maxScatterDistance;
    float secondarySmoothnessMultiplier;
    float primarySmoothnessMultiplier;
    float lobeMix;
    float diffuseShadingPowerMinusOne;
};

SSSProfileData LoadSSSProfile(int index)
{
    index = clamp(index, 0, (int)max(_SSSProfileCount - 1, 0));
    SSSProfileData profile;
    profile.shapeParam = _SSSProfileData0[index].xyz;
    profile.worldScale = _SSSProfileData0[index].w;
    profile.transmissionTint = _SSSProfileData1[index].xyz;
    profile.fresnel0 = _SSSProfileData1[index].w;
    profile.thicknessRemap = _SSSProfileData2[index].xy;
    profile.filterRadius = _SSSProfileData2[index].z;
    profile.maxScatterDistance = _SSSProfileData2[index].w;
    profile.secondarySmoothnessMultiplier = _SSSProfileData3[index].x;
    profile.primarySmoothnessMultiplier = _SSSProfileData3[index].y;
    profile.lobeMix = _SSSProfileData3[index].z;
    profile.diffuseShadingPowerMinusOne = _SSSProfileData3[index].w;
    return profile;
}

#endif
