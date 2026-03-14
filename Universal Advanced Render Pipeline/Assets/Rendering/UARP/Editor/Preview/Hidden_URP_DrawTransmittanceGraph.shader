Shader "Hidden/URP/DrawTransmittanceGraph"
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
            float4 _TransmissionTint;
            float4 _ThicknessRemap;

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

            float3 ComputeTransmittanceDisney(float3 S, float3 volumeAlbedo, float thickness)
            {
                float3 exp_13 = exp2(((LOG2_E * (-1.0 / 3.0)) * thickness) * S);
                return volumeAlbedo * (exp_13 * (exp_13 * exp_13 + 3.0));
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
                float d = _ThicknessRemap.x + input.texcoord.x * (_ThicknessRemap.y - _ThicknessRemap.x);
                float3 S = _ShapeParam.rgb;
                float3 A = _TransmissionTint.rgb;

                S = S * S;
                A = A * A;
                float3 M = ComputeTransmittanceDisney(S, 0.25 * A, d);
                return float4(sqrt(max(M, 0.0)), 1.0);
            }
            ENDHLSL
        }
    }
    Fallback Off
}
