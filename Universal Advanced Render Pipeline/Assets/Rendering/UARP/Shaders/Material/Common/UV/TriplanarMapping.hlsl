#ifndef URPPLUS_UVMAPPING_INCLUDED
#define URPPLUS_UVMAPPING_INCLUDED

struct UVMapping
{
    real2 uv;  // Current uv or planar uv

    // Triplanar specific
    real2 uvZY;
    real2 uvXZ;
    real2 uvXY;

    real3 normalWS; // vertex normal
    real3 triplanarWeights;
};

UVMapping InitializeUVData(real3 position, real3 normalWS, real2 uv)
{
    UVMapping uvData = (UVMapping)0;

    uvData.uv = uv;

    uvData.uvXY = position.xy;
    uvData.uvXZ = position.xz;
    uvData.uvZY = position.zy;

    uvData.normalWS = normalWS;
    uvData.triplanarWeights = ComputeTriplanarWeights(normalWS);

    return uvData;
}

half3 SAMPLE_TEXTURE_TRIPLANAR_RGB(TEXTURE2D_PARAM(textureName, samplerName), UVMapping uvMapping)
{
    half3 val = half3(0.0, 0.0, 0.0);

    if (uvMapping.triplanarWeights.x > 0.0)
        val += uvMapping.triplanarWeights.x * SAMPLE_TEXTURE2D(textureName, samplerName, uvMapping.uvZY).rgb;
    if (uvMapping.triplanarWeights.y > 0.0)
        val += uvMapping.triplanarWeights.y * SAMPLE_TEXTURE2D(textureName, samplerName, uvMapping.uvXZ).rgb;
    if (uvMapping.triplanarWeights.z > 0.0)
        val += uvMapping.triplanarWeights.z * SAMPLE_TEXTURE2D(textureName, samplerName, uvMapping.uvXY).rgb;

    return val;
}

half SAMPLE_TEXTURE_TRIPLANAR_R_LOD(TEXTURE2D_PARAM(textureName, samplerName), UVMapping uvMapping, half lod)
{
    half val = 0.0h;

    if (uvMapping.triplanarWeights.x > 0.0)
        val += uvMapping.triplanarWeights.x * SAMPLE_TEXTURE2D_LOD(textureName, samplerName, uvMapping.uvZY, lod).r;
    if (uvMapping.triplanarWeights.y > 0.0)
        val += uvMapping.triplanarWeights.y * SAMPLE_TEXTURE2D_LOD(textureName, samplerName, uvMapping.uvXZ, lod).r;
    if (uvMapping.triplanarWeights.z > 0.0)
        val += uvMapping.triplanarWeights.z * SAMPLE_TEXTURE2D_LOD(textureName, samplerName, uvMapping.uvXY, lod).r;

    return val;
}

#endif