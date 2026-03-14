Shader "Hidden/URP/SubsurfaceScatteringComposite"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass
        {
            Name "SubsurfaceScatteringComposite"
            ZWrite Off
            ZTest Always
            Cull Off
            Blend One Zero

            HLSLPROGRAM
            #pragma vertex FullscreenVert
            #pragma fragment SSSCompositeFragment
            #include "SubsurfaceScatteringComposite.hlsl"
            ENDHLSL
        }
    }
}
