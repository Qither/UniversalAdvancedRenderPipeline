Shader "UARP/LitTessellation"
{
    Properties
    {
        ///////////////////////////////////////
        /***********Surface Options***********/
        ///////////////////////////////////////
        _WorkflowMode("WorkflowMode", Float) = 1.0
        
        // Blending state
        _Surface("__surface", Float) = 0.0
        _Blend("__blend", Float) = 0.0
        _Cull("__cull", Float) = 2.0
        [HideInInspector] _BlendOp("__blendop", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _SrcBlendAlpha("__srcA", Float) = 1.0
        [HideInInspector] _DstBlendAlpha("__dstA", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _ZTest("ZTest", Int) = 4
        [HideInInspector] _BlendModePreserveSpecular("BlendModePreserveSpecular", Float) = 1.0
        [HideInInspector] _AlphaToMask("__alphaToMask", Float) = 0.0
        [HideInInspector] _AddPrecomputedVelocity("_AddPrecomputedVelocity", Float) = 0.0
        [HideInInspector] _ComputeMeshIndex("Compute Mesh Buffer Index Offset", Float) = 0.0
        
        // Normal Mode
        [Enum(Flip, 0, Mirror, 1, None, 2)] _DoubleSidedNormalMode("Double sided normal mode", Float) = 1
        [HideInInspector] _DoubleSidedConstants("Double-Sided Constants", Vector) = (1.0, 1.0, 1.0, 0.0)
        
        // Alpha Clipping
        [ToggleUI] _AlphaCutoffEnable("Alpha Cutoff Enable", Float) = 0.0
        [ToggleUI] _UseShadowThreshold("UseShadowThreshold", Float) = 0.0
        _AlphaCutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        _AlphaCutoffShadow("AlphaCutoffShadow", Range(0.0, 1.0)) = 0.5

        // Geometric Specular AA
        [ToggleUI] _EnableGeometricSpecularAA("EnableGeometricSpecularAA", Float) = 0.0
        _SpecularAAScreenSpaceVariance("SpecularAAScreenSpaceVariance", Range(0.0, 1.0)) = 0.1
        _SpecularAAThreshold("SpecularAAThreshold", Range(0.0, 1.0)) = 0.2

        // Displacement Mode
        [Enum(None, 0, Tessellation, 1)] _DisplacementMode("DisplacementMode", Float) = 0.0
        [ToggleUI] _DisplacementLockObjectScale("Displacement lock object scale", Float) = 1.0
        [ToggleUI] _DisplacementLockTilingScale("Displacement lock tiling scale", Float) = 1.0
        [ToggleUI] _DepthOffsetEnable("Depth Offset View space", Float) = 0.0
        _PPDMinSamples("Min sample for POM", Range(1.0, 64.0)) = 5
        _PPDMaxSamples("Max sample for POM", Range(1.0, 64.0)) = 15
        _PPDLodThreshold("Start lod to fade out the POM effect", Range(0.0, 16.0)) = 5
        _PPDPrimitiveLength("Primitive length for POM", Float) = 1
        _PPDPrimitiveWidth("Primitive width for POM", Float) = 1
        [HideInInspector] _InvPrimScale("Inverse primitive scale for non-planar POM", Vector) = (1, 1, 0, 0)
        [HideInInspector] _InvTilingScale("Inverse tiling scale = 2 / (abs(_BaseColorMap_ST.x) + abs(_BaseColorMap_ST.y))", Float) = 1

        //////////////////////////////////////
        /********Tessellation Options********/
        //////////////////////////////////////
        [ToggleUI] _PhongTessellationMode("Phong Tessellation mode", Float) = 0.0
        [Enum(None, 0, Edge, 1, Distance, 2)] _TessellationMode("Tessellation mode", Float) = 0
        _TessellationFactor("Tessellation Factor", Range(1.0, 64.0)) = 4.0
        _TessellationEdgeLength("Tessellation Edge Length", Range(5, 100)) = 50
        _TessellationFactorMinDistance("Tessellation start fading distance", Float) = 20.0
        _TessellationFactorMaxDistance("Tessellation end fading distance", Float) = 50.0
        _TessellationShapeFactor("Tessellation shape factor", Range(0.0, 1.0)) = 0.75 // Only use with Phong
        _TessellationBackFaceCullEpsilon("Tessellation back face epsilon", Range(-1.0, 0.0)) = -0.25

        //////////////////////////////////////
        /***********Surface Inputs***********/
        //////////////////////////////////////
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        _AlphaRemapMin("AlphaRemapMin", Range(0.0, 1.0)) = 0.0
        _AlphaRemapMax("AlphaRemapMax", Range(0.0, 1.0)) = 1.0

        _Metallic("_Metallic", Range(0.0, 1.0)) = 0
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _MaskMap("MaskMap", 2D) = "white" {}
        _MetallicRemapMin("MetallicRemapMin", Range(0.0, 1.0)) = 0.0
        _MetallicRemapMax("MetallicRemapMax", Range(0.0, 1.0)) = 1.0
        _SmoothnessRemapMin("SmoothnessRemapMin", Range(0.0, 1.0)) = 0.0
        _SmoothnessRemapMax("SmoothnessRemapMax", Range(0.0, 1.0)) = 1.0
        _AORemapMin("AORemapMin", Range(0.0, 1.0)) = 0.0
        _AORemapMax("AORemapMax", Range(0.0, 1.0)) = 1.0

        _SpecularColor("SpecularColor", Color) = (0.2, 0.2, 0.2, 1.0)
        _SpecularColorMap("SpecularColorMap", 2D) = "white" {}

        [Normal] _NormalMap("NormalMap", 2D) = "bump" {}
        _NormalScale("NormalScale", Range(0.0, 8.0)) = 1

        _ClearCoatMap("ClearCoat Map", 2D) = "white" {}
        _ClearCoatMask("ClearCoat Mask", Range(0.0, 1.0)) = 0.0
        _ClearCoatSmoothness("ClearCoat Smoothness", Range(0.0, 1.0)) = 1.0
        
        [Normal] _CoatNormalMap("Coat Normal Map", 2D) = "bump" {}
        _CoatNormalScale("Coat Normal Scale", Range(0.0, 8.0)) = 1.0

        _HeightMap("Height Map", 2D) = "black" {}
        [HideInInspector] _HeightAmplitude("Height Amplitude", Float) = 0.02 // In world units
        [HideInInspector] _HeightCenter("Height Center", Range(0.0, 1.0)) = 0.5 // In texture space

        [Enum(MinMax, 0, Amplitude, 1)] _HeightMapParametrization("Heightmap Parametrization", Int) = 1
        // MinMax mode
        _HeightMin("Heightmap Min", Float) = -1
        _HeightMax("Heightmap Max", Float) = 1
        // Amplitude mode
        _HeightTessAmplitude("Amplitude", Float) = 2.0 // in Centimeters
        _HeightTessCenter("Height Center", Range(0.0, 1.0)) = 0.5 // In texture space
        // These parameters are for vertex displacement/Tessellation
        _HeightOffset("Height Offset", Float) = 0
        // These parameters are for pixel displacement
        _HeightPoMAmplitude("Height Amplitude", Float) = 2.0 // In centimeters

        ///////////////////////////////////////
        /************Detail Inputs************/
        ///////////////////////////////////////
        _DetailMap("Detail Map", 2D) = "white" {}
        _DetailAlbedoScale("Detail Albedo Scale", Range(0.0, 2.0)) = 1.0
        _DetailNormalScale("Detail Normal Scale", Range(0.0, 2.0)) = 1.0
        _DetailSmoothnessScale("Detail Smoothness Scale", Range(0.0, 2.0)) = 1.0

        //////////////////////////////////////
        /***********Weather Inputs***********/
        //////////////////////////////////////
        [ToggleUI] _WeatherEnable("Weather Enable", Float) = 0.0
        [Enum(Planar, 0, Triplanar, 1)] _RainMode("Rain Mode", Float) = 0

        // Weather Profile
        [HideInInspector] _WeatherProfile("Obsolete, kept for migration purpose", Int) = 0
        [HideInInspector] _WeatherProfileAsset("Weather Profile Asset", Vector) = (0, 0, 0, 0)
        [HideInInspector] _WeatherProfileHash("Weather Profile Hash", Float) = 0
        
        [Normal] _PuddlesNormal("Puddles Normal", 2D) = "bump" {}
        _PuddlesNormalScale("_Puddles Normal Scale", Range(0.0, 8.0)) = 1
        _PuddlesFramesSize("Puddles Frames Size", Vector) = (1.0, 1.0, 0.0, 0.0)
        _PuddlesSize("Puddles Size", Float) = 1
        _PuddlesAnimationSpeed("Puddles Animation Speed", Float) = 1

        [Normal] _RainNormal("Rain Normal", 2D) = "bump" {}
        _RainNormalScale("Rain Normal Scale", Range(0.0, 8.0)) = 1.0
        _RainSize("Rain Size", Float) = 1.0
        _RainAnimationSpeed("Rain Animation Speed", Float) = 0.1
        _RainDistortionMap("Rain Distortion Map", 2D) = "black" {}
        _RainDistortionScale("Rain Distortion Scale", Range(0.0, 2.0)) = 0.5
        _RainDistortionSize("Rain Distortion Size", Float) = 1.0
        _RainWetnessFactor("Rain Wetness Factor", Range(0.0, 1.0)) = 1.0

        _SnowAlbedoMap("SnowAlbedoMap", 2D) = "white" {}
        _SnowDetailMap("SnowDetailMap", 2D) = "white" {}
        _SnowSize("Snow Size", Float) = 1.0

        [ToggleUI] _SnowDisplacementEnable("Snow Displacement", Float) = 0.0
        _SnowHeightMap("Snow Height Map", 2D) = "black" {}
        _SnowHeightMapSize("Snow Height Map Size", Float) = 1.0
        _SnowHeightAmplitude("Snow Height Amplitude", Float) = 0.02
        _SnowHeightCenter("Snow Height Center", Range(0.0, 1.0)) = 0.5

        _SnowCoverage("Snow Coverage", Vector) = (1.0, 1.0, 1.0, 0.0)
        [ToggleUI] _VerticalMaskEnable("VerticalMask Enable", Float) = 0.0
        _SnowRemap("Snow Remap", Vector) = (0.0, 1.0, 1.0, 1.0) // XY: VerticalMask Remap Z: Normal Intensity W: Smoothness Intensity
        _SnowSharpness("Snow Sharpness", Range(0.0, 1.0)) = 0.0

        _WeatherMaskMap("Weather Mask", 2D) = "white" {}

        //////////////////////////////////////
        /*********Transparency Inputs********/
        //////////////////////////////////////
        [Enum(None, 0, Planar, 1, Sphere, 2, Thin, 3)] _RefractionModel("Refraction Model", Int) = 0
        _Ior("Index Of Refraction", Range(-2.0, 2.0)) = 0.0
        _Thickness("Thickness", Range(0.0, 1.0)) = 0.5
        _ThicknessCurvatureMap("Thickness Map", 2D) = "white" {}
        _ThicknessCurvatureRemap("Thickness Remap", Vector) = (0, 1, 0, 1)
        _TransmittanceColor("Transmittance Color", Color) = (1.0, 1.0, 1.0)
        _TransmittanceColorMap("TransmittanceColorMap", 2D) = "white" {}
        _ATDistance("Transmittance Absorption Distance", Float) = 1.0
        _RefractionShadowAttenuation("Refraction Shadow Attenuation", Range(0.0, 1.0)) = 1.0
        [ToggleUI] _ChromaticAberrationEnable("Chromatic Aberration Enable", Float) = 0.0
        _ChromaticAberration("Сhromatic Aberration", Range(0.0, 1.0)) = 0.1
        
        ///////////////////////////////////////
        /***********Emission Inputs***********/
        ///////////////////////////////////////
        [ToggleUI] _EmissionEnable("Emission Enable", Float) = 0.0
        [HDR] _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}
        _EmissionScale("Emission Intensity", Float) = 1.0
        [ToggleUI] _AlbedoAffectEmissive("Albedo Affect Emissive", Float) = 0.0
        [ToggleUI] _EnableEmissionFresnel("Enable Emission Fresnel", Float) = 0.0
        _EmissionFresnelPower("Emission Fresnel Power", Float) = 1.0

        //////////////////////////////////////
        /**********Advanced Options**********/
        //////////////////////////////////////
        [ToggleUI] _CastShadows("Cast Shadows", Float) = 0.0
        [ToggleUI] _ReceiveShadows("Receive Shadows", Float) = 1.0
        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
        [ToggleUI] _CoatNormalEnable("ClearCoat Second Normal", Float) = 0.0
        _QueueOffset("Queue offset", Float) = 0.0

        // Specular Occlusion
        [ToggleOff] _HorizonOcclusion("Horizon Occlusion", Float) = 0.0
        _HorizonFade("HorizonFade", Range(0.0, 1.0)) = 0.5
        [Enum(Off, 0, From Ambient Occlusion, 1, From GI, 2)] _SpecularOcclusionMode("Specular Occlusion Mode", Int) = 0
        _GIOcclusionBias("GIOcclusion Bias", Range(0.0, 1.0)) = 0.0
        
        [ToggleUI] _ComputeDOTSDeformation("Compute DOTS Deformation", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _GlossMapScale("Smoothness", Float) = 0.0
        [HideInInspector] _Glossiness("Smoothness", Float) = 0.0
        [HideInInspector] _GlossyReflections("EnvironmentReflections", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }

    SubShader
    {
        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }
        LOD 300

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForwardOnly"
            }

            // -------------------------------------
            // Render State Commands
            Blend[_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
            ZWrite[_ZWrite]
            ZTest[_ZTest]
            Cull[_Cull]
            AlphaToMask[_AlphaToMask]

            HLSLPROGRAM
            #pragma target 4.5
            #pragma require tessellation tessHW

            #define BASE_PASS_VARYINGS

            // -------------------------------------
            // Shader Stages
            #pragma vertex LitPassVertex
            #pragma hull Hull
            #pragma domain Domain
            #pragma fragment LitPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON _ALPHAMODULATE_ON
            #pragma shader_feature_local _DOUBLESIDED_ON
            #pragma shader_feature_local_fragment _ENABLE_GEOMETRIC_SPECULAR_AA
            #pragma shader_feature_local_fragment _REFRACTION
            #pragma shader_feature_local_fragment _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN
            #pragma shader_feature_local_fragment _CHROMATIC_ABERRATION
            
            #pragma shader_feature_local _TESSELLATION_DISPLACEMENT
            #pragma shader_feature_local _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local _DISPLACEMENT_LOCK_TILING_SCALE
            #pragma shader_feature_local_domain _TESSELLATION_PHONG
            #pragma shader_feature_local _TESSELLATION_EDGE
            #pragma shader_feature_local _TESSELLATION_DISTANCE
            #pragma shader_feature_local_vertex _COMPUTE_DOTS_DEFORMATION

            #pragma shader_feature_local_fragment _MASKMAP
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _THICKNESS_CURVATURE_MAP

            #pragma shader_feature_local _HEIGHTMAP

            #pragma shader_feature_local_fragment _CLEARCOAT
            #pragma shader_feature_local_fragment _CLEARCOATMAP
            #pragma shader_feature_local _COATNORMALMAP

            #pragma shader_feature_local _DETAIL

            #pragma shader_feature_local _WEATHER_ON
            #pragma shader_feature_local_fragment _RAIN_TRIPLANAR
            #pragma shader_feature_local _RAIN_NORMALMAP
            #pragma shader_feature_local_fragment _SNOW_DETAIL
            #pragma shader_feature_local _SNOW_DISPLACEMENT
            #pragma shader_feature_local _SNOW_HEIGHTMAP
            #pragma shader_feature_local _SNOW_VERTICAL_MASK

            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _EMISSION_WITH_BASE
            #pragma shader_feature_local_fragment _EMISSION_FRESNEL

            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _AO_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _GI_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _HORIZON_SPECULAR_OCCLUSION

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile _ _FORWARD_PLUS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            // -------------------------------------
            // ShaderQuality keywords
            #pragma multi_compile_fragment _ _SHADER_QUALITY_MICRO_SHADOWS
            
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            #include "Assets/Rendering/UARP/Shaders/Material/Lit/LitInput.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Lighting/LitLighting.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Vertex/Forward/Tesellation/LitForwardTessellationVertex.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Fragment/Forward/LitForwardFragment.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest[_ZTest]
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 4.5
            #pragma require tessellation tessHW

            #define SHADOW_PASS_VARYINGS

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma hull Hull
            #pragma domain ShadowDomain
            #pragma fragment ShadowPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SHADOW_CUTOFF

            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _TESSELLATION_DISPLACEMENT
            #pragma shader_feature_local _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local _DISPLACEMENT_LOCK_TILING_SCALE
            #pragma shader_feature_local_domain _TESSELLATION_PHONG
            #pragma shader_feature_local _TESSELLATION_EDGE
            #pragma shader_feature_local _TESSELLATION_DISTANCE
            #pragma shader_feature_local_vertex _COMPUTE_DOTS_DEFORMATION
            
            #pragma shader_feature_local _SNOW_DISPLACEMENT
            #pragma shader_feature_local _SNOW_HEIGHTMAP
            #pragma shader_feature_local _SNOW_VERTICAL_MASK

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // -------------------------------------
            // Includes
            #include "Assets/Rendering/UARP/Shaders/Material/Lit/LitInput.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/ShadowCaster/Vertex/ShadowCasterTessallationVertex.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/ShadowCaster/Fragment/ShadowCasterFragment.hlsl"
            ENDHLSL
        }

        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite[_ZWrite]
            ZTest[_ZTest]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 4.5
            #pragma require tessellation tessHW

            #define BASE_PASS_VARYINGS

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Shader Stages
            #pragma vertex LitGBufferPassVertex
            #pragma hull Hull
            #pragma domain Domain
            #pragma fragment LitGBufferPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            //#pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local _DOUBLESIDED_ON
            #pragma shader_feature_local_fragment _ENABLE_GEOMETRIC_SPECULAR_AA
            #pragma shader_feature_local_fragment _REFRACTION
            #pragma shader_feature_local_fragment _ _REFRACTION_PLANE _REFRACTION_SPHERE _REFRACTION_THIN
            #pragma shader_feature_local_fragment _CHROMATIC_ABERRATION

            #pragma shader_feature_local _TESSELLATION_DISPLACEMENT
            #pragma shader_feature_local _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local _DISPLACEMENT_LOCK_TILING_SCALE
            #pragma shader_feature_local_domain _TESSELLATION_PHONG
            #pragma shader_feature_local _TESSELLATION_EDGE
            #pragma shader_feature_local _TESSELLATION_DISTANCE
            #pragma shader_feature_local_vertex _COMPUTE_DOTS_DEFORMATION

            #pragma shader_feature_local_fragment _MASKMAP
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _THICKNESS_CURVATURE_MAP

            #pragma shader_feature_local _HEIGHTMAP

            #pragma shader_feature_local_fragment _CLEARCOAT
            #pragma shader_feature_local_fragment _CLEARCOATMAP
            #pragma shader_feature_local _COATNORMALMAP

            #pragma shader_feature_local _DETAIL

            #pragma shader_feature_local _WEATHER_ON
            #pragma shader_feature_local_fragment _RAIN_TRIPLANAR
            #pragma shader_feature_local _RAIN_NORMALMAP
            #pragma shader_feature_local_fragment _SNOW_DETAIL
            #pragma shader_feature_local _SNOW_DISPLACEMENT
            #pragma shader_feature_local _SNOW_HEIGHTMAP
            #pragma shader_feature_local _SNOW_VERTICAL_MASK

            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _EMISSION_WITH_BASE
            #pragma shader_feature_local_fragment _EMISSION_FRESNEL

            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _AO_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _GI_SPECULAR_OCCLUSION
            #pragma shader_feature_local_fragment _HORIZON_SPECULAR_OCCLUSION

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            // -------------------------------------
            // ShaderQuality keywords
            #pragma multi_compile_fragment _ _SHADER_QUALITY_MICRO_SHADOWS

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Assets/Rendering/UARP/Shaders/Material/Lit/LitInput.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Lighting/LitLighting.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Vertex/Deferred/Tessellation/LitTessellationDeferredVertex.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Renderer/Fragment/Deferred/LitDeferredFragment.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest[_ZTest]
            ColorMask R
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 4.5
            #pragma require tessellation tessHW

            #define DEPTH_PASS_VARYINGS

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthOnlyVertex
            #pragma hull Hull
            #pragma domain DepthDomain
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            #pragma shader_feature_local _TESSELLATION_DISPLACEMENT
            #pragma shader_feature_local _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local _DISPLACEMENT_LOCK_TILING_SCALE
            #pragma shader_feature_local_domain _TESSELLATION_PHONG
            #pragma shader_feature_local _TESSELLATION_EDGE
            #pragma shader_feature_local _TESSELLATION_DISTANCE
            #pragma shader_feature_local_vertex _COMPUTE_DOTS_DEFORMATION

            #pragma shader_feature_local _HEIGHTMAP

            #pragma shader_feature_local _SNOW_DISPLACEMENT
            #pragma shader_feature_local _SNOW_HEIGHTMAP
            #pragma shader_feature_local _SNOW_VERTICAL_MASK

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Assets/Rendering/UARP/Shaders/Material/Lit/LitInput.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthOnly/Vertex/DepthOnlyTessellationVertex.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthOnly/Fragment/DepthOnlyFragment.hlsl"
            ENDHLSL
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture with the forward renderer or the depthNormal prepass with the deferred renderer.
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest[_ZTest]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 4.5
            #pragma require tessellation tessHW

            #define DEPTH_NORMALS_PASS_VARYINGS

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthNormalsVertex
            #pragma hull Hull
            #pragma domain DepthNormalsDomain
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local _DOUBLESIDED_ON

            #pragma shader_feature_local _TESSELLATION_DISPLACEMENT
            #pragma shader_feature_local _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local _DISPLACEMENT_LOCK_TILING_SCALE
            #pragma shader_feature_local_domain _TESSELLATION_PHONG
            #pragma shader_feature_local _TESSELLATION_EDGE
            #pragma shader_feature_local _TESSELLATION_DISTANCE
            #pragma shader_feature_local_vertex _COMPUTE_DOTS_DEFORMATION

            #pragma shader_feature_local_fragment _MASKMAP
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _DETAIL

            #pragma shader_feature_local _HEIGHTMAP

            #pragma shader_feature_local _SNOW_DISPLACEMENT
            #pragma shader_feature_local _SNOW_HEIGHTMAP
            #pragma shader_feature_local _SNOW_VERTICAL_MASK

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT // forward-only variant
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Assets/Rendering/UARP/Shaders/Material/Lit/LitInput.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthNormals/LitDepthNormals.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthNormals/Vertex/DepthNormalsTessellationVertex.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/DepthNormals/Fragment/LitDepthNormalsFragment.hlsl"
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // -------------------------------------
            // Render State Commands
            Cull Off

            HLSLPROGRAM
            #pragma target 4.5
            #pragma require tessellation tessHW

            #define META_PASS_VARYINGS

            // -------------------------------------
            // Shader Stages
            #pragma vertex VertexMeta
            #pragma hull Hull
            #pragma domain MetaDomain
            #pragma fragment FragmentMeta

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            #pragma shader_feature_local_fragment _MASKMAP
            #pragma shader_feature_local _NORMALMAP

            #pragma shader_feature_local _DETAIL

            #pragma shader_feature_local _HEIGHTMAP
            #pragma shader_feature_local _TESSELLATION_DISPLACEMENT
            #pragma shader_feature_local _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
            #pragma shader_feature_local _DISPLACEMENT_LOCK_TILING_SCALE
            #pragma shader_feature_local_domain _TESSELLATION_PHONG
            #pragma shader_feature_local_vertex _COMPUTE_DOTS_DEFORMATION

            #pragma shader_feature_local _SNOW_DISPLACEMENT
            #pragma shader_feature_local _SNOW_HEIGHTMAP
            #pragma shader_feature_local _SNOW_VERTICAL_MASK

            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _EMISSION_WITH_BASE
            #pragma shader_feature EDITOR_VISUALIZATION

            // -------------------------------------
            // Includes
            #include "Assets/Rendering/UARP/Shaders/Material/Lit/LitInput.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Lighting/LitLighting.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Meta/Vertex/MetaTessallationVertex.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Meta/Fragment/MetaFragment.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Universal2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // -------------------------------------
            // Render State Commands
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 4.5

            // -------------------------------------
            // Shader Stages
            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON

            // -------------------------------------
            // Includes
            #include "Assets/Rendering/UARP/Shaders/Material/Lit/LitInput.hlsl"
            #include "Assets/Rendering/UARP/Shaders/Material/Common/Passes/Universal2D.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "MotionVectors"
            Tags { "LightMode" = "MotionVectors" }
            ColorMask RG

            HLSLPROGRAM
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #pragma shader_feature_local_vertex _ADD_PRECOMPUTED_VELOCITY

            #include "Assets/Rendering/UARP/Shaders/Material/Lit/LitInput.hlsl"
            #include_with_pragmas "Assets/Rendering/UARP/Shaders/Material/Common/Passes/ObjectMotionVectors.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "XRMotionVectors"
            Tags { "LightMode" = "XRMotionVectors" }
            ColorMask RGB

            // Stencil write for obj motion pixels
            Stencil
            {
                WriteMask 1
                Ref 1
                Comp Always
                Pass Replace
            }

            HLSLPROGRAM
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma shader_feature_local_vertex _ADD_PRECOMPUTED_VELOCITY
            #define APLICATION_SPACE_WARP_MOTION 1

            #include "Assets/Rendering/UARP/Shaders/Material/Lit/LitInput.hlsl"
            #include_with_pragmas "Assets/Rendering/UARP/Shaders/Material/Common/Passes/ObjectMotionVectors.hlsl"
            ENDHLSL
        }
    }

    //////////////////////////////////////////////////////

    FallBack "Hidden/Universal Render Pipeline/Lit"
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
