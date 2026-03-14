Shader "UARP/Lit"
{
    Properties
    {
        [MainColor] _BaseColor("BaseColor", Color) = (1,1,1,1)
        [MainTexture] _BaseColorMap("BaseColorMap", 2D) = "white" {}
        _NormalMap("NormalMap", 2D) = "bump" {}
        _NormalScale("_NormalScale", Range(0.0, 8.0)) = 1
        _SubsurfaceMask("Subsurface Radius", Range(0.0, 1.0)) = 1.0
        _SubsurfaceMaskMap("Subsurface Radius Map", 2D) = "white" {}
        _TransmissionMask("Transmission Mask", Range(0.0, 1.0)) = 1.0
        _TransmissionMaskMap("Transmission Mask Map", 2D) = "white" {}
        _Thickness("Thickness", Float) = 1.0
        _ThicknessMap("Thickness Map", 2D) = "white" {}
        _ThicknessRemap("Thickness Remap", Vector) = (0, 1, 0, 0)
        [ToggleUI] _TransmissionEnable("_TransmissionEnable", Float) = 1.0
        [HideInInspector]_DiffusionProfileAsset("Diffusion Profile Asset", Vector) = (0, 0, 0, 0)
        [HideInInspector]_DiffusionProfileHash("Diffusion Profile Hash", Float) = 0
        [HideInInspector]_DiffusionProfileIndex("Diffusion Profile Index", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM
            #pragma vertex LitVertex
            #pragma fragment LitForwardFragment
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #include "LitForwardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "SSSMeta"
            Tags { "LightMode" = "SSSMeta" }
            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex LitVertex
            #pragma fragment LitMetaFragment
            #include "LitMetaPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "SSSDiffuse"
            Tags { "LightMode" = "SSSDiffuse" }
            HLSLPROGRAM
            #pragma vertex LitVertex
            #pragma fragment LitDiffuseFragment
            #include "LitDiffusePass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthNormalsOnly"
            Tags { "LightMode" = "DepthNormalsOnly" }
            HLSLPROGRAM
            #pragma vertex LitVertex
            #pragma fragment LitDepthNormalsFragment
            #include "LitDepthNormalsPass.hlsl"
            ENDHLSL
        }
    }

    CustomEditor "URPDiffusionProfile.EditorTools.LitGUI"
}
