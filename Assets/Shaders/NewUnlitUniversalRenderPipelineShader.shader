Shader "Rob/NewUnlitUniversalRenderPipelineShader"
{
    Properties
    {
        _myColor("Sample Color", color) = (1,1,1,1) 
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
           };

           struct Varyings
           {
                float4 positionHCS : SV_POSITION;    
           };

           float4 _myColor;

           Varyings vert(Attributes IN)
           {
               Varyings OUT;
               OUT.positionHCS = TransformObjectToHClip(IN.position05.xyz);
               return OUT;
           }
           
           half4 frag(Varyings IN) : SV_Target
           {
               return _myColor;
           }
           ENDHLSL
        }
    }
    FallBack Off
}
