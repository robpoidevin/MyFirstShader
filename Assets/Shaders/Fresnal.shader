Shader "Custom/RimLightShader"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        [Keyword(UV0,UV1)] _UVSET ("UV Set", Float)=0

        //optionl rim demo
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0.5, 8)) = 3
        _RimStrength ("Rim Strength", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline" }
        LOD 200

        Pass
        {
            Name "Unlit"
            Tags{"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #pragma shader_feature_local _UVSET_UV0 _UVSET_UV1
            struct Attributes
            {
                float3 normalOS : NORMAL;
                float4 positionOS : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                float4 _RimColor;
                float _RimPower;
                float _RimStrength;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);
                float3 nrmWS = TransformObjectToWorldNormal (IN.normalOS);

                OUT.positionWS = posWS;
                OUT.normalWS = nrmWS;
                OUT.positionHCS = TransformWorldToHClip(posWS);

                #if defined (_UVSET_UV1)
                    OUT.uv = TRANSFORM_TEX(IN.uv1, _BaseMap);
                #else
                    OUT.uv = TRANSFORM_TEX(IN.uv0, _BaseMap);
                #endif

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                half3 finalColor = color.rgb * _BaseColor.rgb;

                float3 viewDirWS = GetWorldSpaceViewDir(IN.positionWS);
                viewDirWS = SafeNormalize(viewDirWS);

                float3 n = SafeNormalize(IN.normalWS);
                float ndotv = saturate(dot(n, viewDirWS));
                float fres = pow(1.0 - ndotv, _RimPower);
                finalColor += (_RimColor.rgb * fres) * _RimStrength;

                return half4(finalColor, 1.0);
            }
            ENDHLSL
        }
    }
}