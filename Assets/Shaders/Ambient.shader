Shader "Alvaro/URP/Ambient"
{
	Properties
	{
		_BaseColor ("Base Color", Color) = (1, 1, 1, 1) // Base color of the object
		_MainTex ("Base Texture", 2D) = "white" {} // Texture map
	}
	SubShader
	{
		Tags { "RenderPipeline" = "UniversalRenderPipeline" "RenderType" = "Opaque" }
		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			struct Attributes
			{
				float4 positionOS : POSITION;
				float2 uv : TEXCOORD0; // Texture UV coordinates
				float3 normalOS : NORMAL; // Object space normal
			};
			struct Varyings
			{
				float4 positionHCS : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
			};

			TEXTURE2D(_MainTex); // Texture reference
			SAMPLER(sampler_MainTex); // Texture sampler

			CBUFFER_START(UnityPerMaterial)
				float4 _BaseColor; // Base color (inspector-settable)
			CBUFFER_END

			Varyings vert(Attributes IN)
			{
				Varyings OUT;
				OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz); // Convert to homogeneous clip space
				OUT.uv = IN.uv; // Pass UV to fragment shader
				OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS)); // Transform normals to world space
				return OUT;
			}
			half4 frag(Varyings IN) : SV_Target
			{
				// Sample texture color
				half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
				// Combine with base color
				half3 normalWS = normalize(IN.normalWS);
				Light mainLight = GetMainLight(); // Fetch main directional light
				half3 lightDir = normalize(mainLight.direction);
				half NdotL = saturate(dot(normalWS, lightDir)); // Lambertian lighting calculation
				half3 ambientSH = SampleSH(normalWS);
				half3 diffuse = texColor.rgb * _BaseColor.rbg * NdotL;
				half3 finalColor = diffuse + ambientSH * texColor.rgb * _BaseColor.rgb;
				return half4(finalColor,1.0);
			}
			ENDHLSL
		}
}}