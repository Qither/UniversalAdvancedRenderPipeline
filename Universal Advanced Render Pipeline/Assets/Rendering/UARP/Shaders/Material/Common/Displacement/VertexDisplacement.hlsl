#ifndef URPPLUS_VERTEX_DISPLACEMENT_INCLUDED
#define URPPLUS_VERTEX_DISPLACEMENT_INCLUDED

#if defined (_SNOW_DISPLACEMENT) && (_SNOW_HEIGHTMAP)
    #include "Assets/Rendering/UARP/Shaders/Material/Common/Weather/Snow.hlsl"
#endif

#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/DisplacementUtils.hlsl"

float3 ComputePerVertexDisplacement(TEXTURE2D_PARAM(heightMap, sampler_heightMap), float2 uv, float lod)
{
    #ifdef _HEIGHTMAP
    float height = (SAMPLE_TEXTURE2D_LOD(heightMap, sampler_heightMap, uv, lod).r - _HeightCenter) * _HeightAmplitude;
        #if defined(LOD_FADE_CROSSFADE) && defined(_TESSELLATION_DISPLACEMENT)
            height *= unity_LODFade.x;
        #endif
    #else
    float height = 0.0;
    #endif

    // Height is affected by tiling property and by object scale (depends on option).
    // Apply scaling from tiling properties (TexWorldScale and tiling from BaseColor)
    ApplyDisplacementTileScale(height);
    // Applying scaling of the object if requested
    #ifdef _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
    float3 objectScale = GetDisplacementObjectScale(true);
    return height.xxx * objectScale;
    #else
    return height.xxx;
    #endif
}

real3 ApplyVertexDisplacementWS(real3 positionOS, real3 normalWS, float2 uv)
{
    real3 positionWS = TransformObjectToWorld(positionOS);

    half3 height = half3(0.0, 0.0, 0.0);
    #if defined (_VERTEX_DISPLACEMENT) || (_TESSELLATION_DISPLACEMENT)
        height = ComputePerVertexDisplacement(_HeightMap, sampler_HeightMap, uv, 1);
    #endif
    #if defined (_SNOW_DISPLACEMENT) && (_SNOW_HEIGHTMAP)
        UVMapping uvMapping = InitializeUVData(positionWS, normalWS, uv);
        height += ComputePerVertexSnowHeightMap(uvMapping, positionOS);
    #endif
    #if defined (_VERTEX_DISPLACEMENT) || (_TESSELLATION_DISPLACEMENT) || (_SNOW_DISPLACEMENT)
        positionWS += normalWS * height;
    #endif

    return positionWS;
}

VertexPositionInputs CalculateVertexPositionInputs(real3 positionOS, real3 normalWS, float2 uv)
{
    VertexPositionInputs input;
    
    input.positionWS = ApplyVertexDisplacementWS(positionOS, normalWS, uv);
    input.positionVS = TransformWorldToView(input.positionWS);
    input.positionCS = TransformWorldToHClip(input.positionWS);

    float4 ndc = input.positionCS * 0.5f;
    input.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
    input.positionNDC.zw = input.positionCS.zw;

    return input;
}

#endif