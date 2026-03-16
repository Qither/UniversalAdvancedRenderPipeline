#ifndef URPPLUS_HAIR_META_PASS_INCLUDED
#define URPPLUS_HAIR_META_PASS_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Meta/MetaInput.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Meta/Varyings.hlsl"

half4 UniversalFragmentMeta(Varyings fragIn, MetaInput metaInput)
{
    #ifdef EDITOR_VISUALIZATION
    metaInput.VizUV = fragIn.VizUV;
    metaInput.LightCoord = fragIn.LightCoord;
    #endif

    return UnityMetaFragment(metaInput);
}

half4 FragmentMetaHair(Varyings input) : SV_Target
{
    SurfaceData surfaceData;
    HairData hairData;
    InitializeSurfaceData(input.uv, surfaceData, hairData);

    BRDFData brdfData;
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

    MetaInput metaInput;
    metaInput.Albedo = brdfData.diffuse + brdfData.specular * brdfData.roughness * 0.5;
    metaInput.Emission = surfaceData.emission;
    return UniversalFragmentMeta(input, metaInput);
}

#endif