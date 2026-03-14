Shader "Hidden/URP/DrawDiffusionProfile"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass
        {
            Cull Off
            ZTest Always
            ZWrite Off
            Blend Off

            HLSLPROGRAM
            #pragma editor_sync_compilation
            #pragma target 4.5
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"

            float4 _ShapeParam;
            float _MaxRadius;

            struct Attributes
            {
                float3 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            float3 EvalBurleyDiffusionProfile(float r, float3 s)
            {
                float rr = max(r, 1e-4);
                return s * (exp(-rr * s) + exp(-rr * s * (1.0 / 3.0))) / (8.0 * PI);
            }

            Varyings Vert(Attributes input)
            {
                Varyings output;
                output.vertex = mul(unity_MatrixVP, float4(input.vertex, 1.0));
                output.texcoord = input.texcoord.xy;
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                float r = _MaxRadius * 0.5 * length(input.texcoord - 0.5);
                float3 S = _ShapeParam.rgb;
                float safeR = max(r, 1e-4);

                S = S * S;
                float3 M = EvalBurleyDiffusionProfile(r, S) / safeR;
                return float4(sqrt(max(M, 0.0)), 1.0);
            }
            ENDHLSL
        }
    }
    Fallback Off
}
