Shader "Custom/CompletedRimLightShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Normal ("Normal (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_RimColor ("Rim Color", Color) = (1, 1, 1, 1)
		_RimPower ("Rim Power", Range(0, 5)) = 1
		_FlashSpeed ("Flash Speed", Range(0.1, 10)) = 3
		_RimMinimum ("Rim Minimum", Range(0, 1)) = 0.2
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Normal;

		struct Input {
			float2 uv_MainTex;
			float3 viewDir;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _RimColor;
		float _RimLowerThreshold;
		float _RimUpperThreshold;
		float _RimPower;
		float _FlashSpeed;
		float _RimMinimum;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_MainTex));

			float sinOutput = sin(_Time.z * _FlashSpeed);
			float timeScale = _RimMinimum + smoothstep(-1 + _RimMinimum, 1 + _RimMinimum, sinOutput + _RimMinimum);
			float surfaceDir = (1 - dot(normalize(IN.viewDir), o.Normal));
			float steppedScale = surfaceDir * timeScale;

			o.Albedo = c.rgb;
			o.Emission = _RimColor.rgb * steppedScale * _RimPower;

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
