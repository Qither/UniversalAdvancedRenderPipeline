Shader "Hidden/URP/SubsurfaceScatteringResolve"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass
        {
            Name "SubsurfaceScatteringResolve"
            ZWrite Off
            ZTest Always
            Cull Off
            Blend One Zero

            HLSLPROGRAM
            #pragma vertex FullscreenVert
            #pragma fragment SSSResolveFragment
            #include "SubsurfaceScatteringResolve.hlsl"
            ENDHLSL
        }
    }
}
