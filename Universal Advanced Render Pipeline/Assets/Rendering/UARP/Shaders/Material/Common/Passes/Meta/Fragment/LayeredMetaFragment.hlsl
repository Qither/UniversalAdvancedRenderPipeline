#ifndef URPPLUS_LAYERED_LIT_META_PASS_INCLUDED
#define URPPLUS_LAYERED_LIT_META_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/LayeredLit/LayeredDisplacement.hlsl"
#include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Meta/Varyings.hlsl"

half4 UniversalFragmentMeta(Varyings fragIn, MetaInput metaInput)
{
    #ifdef EDITOR_VISUALIZATION
    metaInput.VizUV = fragIn.VizUV;
    metaInput.LightCoord = fragIn.LightCoord;
    #endif

    return UnityMetaFragment(metaInput);
}

half4 LayeredLitFragmentMeta(Varyings input) : SV_Target
{
    half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
    #if defined(REQUIRE_VERTEX_COLOR)
    vertexColor = input.vertexColor;
    #endif

    LayerTexCoord layerTexCoord;
    InitializeTexCoordinates(input.uv, layerTexCoord);

    LayeredData layeredData;
    InitializeLayeredData(layerTexCoord, layeredData);

    SurfaceData surfaceData;
    InitializeSurfaceData(layerTexCoord, vertexColor, surfaceData);

    BRDFData brdfData;
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

    MetaInput metaInput;
    metaInput.Albedo = brdfData.diffuse + brdfData.specular * brdfData.roughness * 0.5;
    metaInput.Emission = surfaceData.emission;

    return UniversalFragmentMeta(input, metaInput);
}

#endif