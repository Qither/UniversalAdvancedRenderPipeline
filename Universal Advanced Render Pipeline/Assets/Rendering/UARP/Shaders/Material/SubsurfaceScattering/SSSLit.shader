// SSS Lit Shader - Subsurface Scattering with Standard Lit Workflow

Shader "UARP/LitSSS"
{
    Properties
    {
        [Header(Surface Options)]
        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull                       ("Culling", Float) = 2
        [Toggle(_ALPHATEST_ON)]
        _AlphaClip                  ("Alpha Clipping", Float) = 0.0
        _Cutoff                     ("     Threshold", Range(0.0, 1.0)) = 0.5
        [ToggleOff(_RECEIVE_SHADOWS_OFF)]
        _ReceiveShadows             ("Receive Shadows", Float) = 1.0

        [Header(Subsurface Scattering)]
        _DiffusionProfileAsset      ("Diffusion Profile", Vector) = (0, 0, 0, 0)
        _DiffusionProfileHash       ("Diffusion Profile Hash", Float) = 0
        _SubsurfaceMask             ("Subsurface Mask", Range(0.0, 1.0)) = 1.0
        _SubsurfaceMaskMap          ("Subsurface Mask Map", 2D) = "white" {}
        _TransmissionMask           ("Transmission Mask", Range(0.0, 1.0)) = 1.0
        _TransmissionMaskMap        ("Transmission Mask Map", 2D) = "white" {}
        _Thickness                  ("Thickness", Range(0.0, 1.0)) = 1.0
        _ThicknessMap               ("Thickness Map", 2D) = "white" {}

        [Header(Surface Inputs)]
        _WorkflowMode               ("Workflow Mode", Float) = 1.0

        [MainColor]
        _BaseColor                  ("Color", Color) = (1,1,1,1)
        [MainTexture]
        _BaseMap                    ("Albedo", 2D) = "white" {}

        _Smoothness                 ("Smoothness", Range(0.0, 1.0)) = 0.5
        _SmoothnessTextureChannel   ("Smoothness Texture Channel", Float) = 0

        _Metallic                   ("Metallic", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap           ("Metallic Map", 2D) = "white" {}

        _SpecColor                  ("Specular", Color) = (0.2, 0.2, 0.2)
        _SpecGlossMap               ("Specular Map", 2D) = "white" {}

        [Toggle(_NORMALMAP)]
        _ApplyNormal                ("Enable Normal Map", Float) = 0.0
        [NoScaleOffset]
        _BumpMap                    ("     Normal Map", 2D) = "bump" {}
        _BumpScale                  ("     Normal Scale", Float) = 1.0

        [Toggle(_OCCLUSIONMAP)]
        _EnableOcclusion            ("Enable Occlusion", Float) = 0.0
        _OcclusionMap               ("     Occlusion", 2D) = "white" {}
        _OcclusionStrength          ("     Occlusion Strength", Range(0.0, 1.0)) = 1.0

        [HDR]
        _EmissionColor              ("Emission Color", Color) = (0,0,0)
        [NoScaleOffset]
        _EmissionMap                ("Emission Map", 2D) = "white" {}

        [Header(Advanced)]
        [ToggleOff(_SPECULARHIGHLIGHTS_OFF)]
        _SpecularHighlights         ("Specular Highlights", Float) = 1.0
        [ToggleOff(_ENVIRONMENTREFLECTIONS_OFF)]
        _EnvironmentReflections     ("Environment Reflections", Float) = 1.0

        [Header(Render Queue)]
        [IntRange] _QueueOffset     ("Queue Offset", Range(-50, 50)) = 0

        // Lightmapper and outline selection shader need _MainTex, _Color and _Cutoff
        [HideInInspector] _MainTex  ("Albedo", 2D) = "white" {}
        [HideInInspector] _Color    ("Color", Color) = (1,1,1,1)
        
        // Blending state
        [HideInInspector] _Surface  ("__surface", Float) = 0.0
        [HideInInspector] _Blend    ("__blend", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _SrcBlendAlpha("__srcA", Float) = 1.0
        [HideInInspector] _DstBlendAlpha("__dstA", Float) = 0.0
        [HideInInspector] _ZWrite   ("__zw", Float) = 1.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }
        LOD 300

    //  SSSBuffer Pass - Split Lighting Output -----------------------------------------------------
        Pass
        {
            Name "SSSBuffer"
            Tags
            {
                "LightMode" = "SSSBuffer"
            }

            Stencil {
                Ref   4        // STENCILUSAGE_SUBSURFACE_SCATTERING
                ReadMask 255
                WriteMask 255
                Comp  Always   // Always write stencil
                Pass  Replace  // Replace stencil value with 4
                Fail  Keep
                ZFail Keep
            }

            ZWrite On
            Cull [_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex SSSBufferVertex
            #pragma fragment SSSBufferFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _SUBSURFACE_MASK_MAP
            #pragma shader_feature_local_fragment _TRANSMISSION_MASK_MAP
            #pragma shader_feature_local_fragment _THICKNESS_MAP

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _LIGHT_LAYERS
            #if UNITY_VERSION >= 60000000
            #pragma multi_compile _ _CLUSTER_LIGHT_LOOP
            #else
            #pragma multi_compile _ _FORWARD_PLUS
            #endif
            #if UNITY_VERSION >= 60000000
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #endif
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

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
            #if UNITY_VERSION >= 60000000
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
            #endif

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // Define SHADERPASS for texturing mode logic
            #include "Assets/Rendering/UARP/Shaders/Material/SubsurfaceScattering/Includes/ShaderPass.cs.hlsl"
            #define SHADERPASS SHADERPASS_FORWARD_SSSBUFFER

            // Note: SSSLitForwardPass.hlsl includes SSSLitInput.hlsl which defines UnityPerMaterial CBUFFER
            #include "Assets/Rendering/UARP/Shaders/Material/SubsurfaceScattering/Includes/SSSLitForwardPass.hlsl"

            ENDHLSL
        }

    //  ShadowCaster Pass -----------------------------------------------------
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            #include "Assets/Rendering/UARP/Shaders/Material/SubsurfaceScattering/Includes/SSSLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"

            ENDHLSL
        }

    //  DepthOnly Pass -----------------------------------------------------
        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask R
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            #include "Assets/Rendering/UARP/Shaders/Material/SubsurfaceScattering/Includes/SSSLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"

            ENDHLSL
        }

    //  DepthNormal Pass -----------------------------------------------------
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            // -------------------------------------
            // Universal Pipeline keywords
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            #include "Assets/Rendering/UARP/Shaders/Material/SubsurfaceScattering/Includes/SSSLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"

            ENDHLSL
        }

    //  Meta Pass -----------------------------------------------------
        Pass
        {
            Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _SPECGLOSSMAP
            #pragma shader_feature EDITOR_VISUALIZATION

            #include "Assets/Rendering/UARP/Shaders/Material/SubsurfaceScattering/Includes/SSSLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"

            ENDHLSL
        }

    //  MotionVectors Pass -----------------------------------------------------
        Pass
        {
            Name "MotionVectors"
            Tags { "LightMode" = "MotionVectors" }
            
            ColorMask RG
            Cull[_Cull]

            HLSLPROGRAM
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma shader_feature_local_vertex _ADD_PRECOMPUTED_VELOCITY

            #include "Assets/Rendering/UARP/Shaders/Material/SubsurfaceScattering/Includes/SSSLitInput.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ObjectMotionVectors.hlsl"

            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "UARP.Rendering.SubsurfaceScattering.Editor.SSSLitShaderGUI"
}

