Shader "Rob/NewUnlitUniversalRenderPipelineShader"
{
    Properties
    {
        _BaseColor("Base Color", color) = (1,1,1,1) 
        _BaseMap("Base Map", 2D) = "white"
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100

        Pass
        {
           Name "Unlit"
           Tags {"LightMode" = "UniversalForward"}

           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

           struct Attributes
           {
                float4 position05 : POSITION; 
                float2 uv : TEXCOORD0;
           };

           struct Varyings
           {
                float4 positionHCS : SV_POSITION;  
                float2 uv : TEXCOORD0;
           };

           float4 _myColor;
           TEXTURE2D(_BaseMap);
           SAMPLER(sampler_BaseMap);

           CBUFFER_START(UnityPerMaterial)
           half4 _BaseColor;
           float4 _BaseMap_ST;
           CBUFFER_END
           Varyings vert(Attributes IN)
           {
               Varyings OUT;
               OUT.positionHCS = TransformObjectToHClip(IN.position05.xyz);
               OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
               return OUT;
           }
           
           half4 frag(Varyings IN) : SV_Target
           {
               half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
half4 finalColor = color * _BaseColor;
return finalColor;
           }
           ENDHLSL
        }
    }
    FallBack Off
}
