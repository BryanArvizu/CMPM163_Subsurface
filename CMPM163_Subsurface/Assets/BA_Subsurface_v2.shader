Shader "Custom/BA_Subsurface_v2"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Distortion("Distortion", Range(0,1)) = 0.5
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_DepthMask("Depth Mask", 2D) = "white" {}
		_DepthStr("Depth Mask Strength", Float) = 1
		_Scale("Scale", Float) = 1
		_Power("Power", Float) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf StandardTranslucent noshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_DepthMask;
			float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
		float _Power;
		float _Scale;
		half _Distortion;
		sampler2D _DepthMask;
		float _DepthStr;

		float thickness;

		#include "UnityPBSLighting.cginc"
		inline fixed4 LightingStandardTranslucent(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi)
		{
			// Original colour
			fixed4 pbr = LightingStandard(s, viewDir, gi);

			// --- Translucency ---
			float3 L = gi.light.dir;
			float3 V = viewDir;
			float3 N = s.Normal;
			float3 H = normalize(L + N * _Distortion);
			float I = pow(saturate(dot(V, -H)), _Power) * _Scale * thickness;

			// Final add
			pbr.rgb = pbr.rgb + gi.light.color * I;
			return pbr;
		}

		void LightingStandardTranslucent_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
			LightingStandard_GI(s, data, gi);
		}

		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			clip(c.a - 0.25);

			thickness = tex2D(_DepthMask, IN.uv_DepthMask).r * _DepthStr;

            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
