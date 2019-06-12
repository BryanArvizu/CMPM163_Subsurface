Shader "Custom/BA_Subsurface"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1, 1, 1, 1)
		_SubLight ("Passthrough", Color) = (0.6, 0.8, 0.9, 1)
		_Ambience("Ambience", Color) = (1, 1, 1, 1)
		_Shininess("Shininess", Float) = 10 //Shininess
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Tags { "LightMode" = "ForwardAdd" }
			//Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			uniform float4 _LightColor0; //From UnityCG

			sampler2D _MainTex;
			float4 _MainTex_ST;
			uniform float4 _Color;
			uniform float4 _SubLight;
			uniform float4 _Ambience;
			uniform float _Shininess;

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal :NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float4 vertexInWorldCoords : TEXCOORD1;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertexInWorldCoords = mul(unity_ObjectToWorld, v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float3 P = i.vertexInWorldCoords.xyz;
				float3 N = normalize(i.normal);
				float3 V = normalize(_WorldSpaceCameraPos - P);
				float3 L = normalize(_WorldSpaceLightPos0.xyz - P);
				float3 H = normalize(L + V);

				// AMBIENT
				float3 ambient = _Ambience;

				// DIFFUSE
				float ndotl = dot(N, L);
				float3 diffuse;
				if (ndotl > 0)
					diffuse = _LightColor0.rgb * _Color.rgb * ndotl;
				else
					diffuse = (_LightColor0.rgb * _SubLight) * _Color.rgb * abs(dot(V, L));
				

				//SPECULAR LIGHT
				float specularVal = pow(max(dot(N, H), 0), _Shininess);

				if (ndotl <= 0) {
					specularVal = 0;
				}

				float3 specular = float3(0, 0, 0) * _LightColor0.rgb * specularVal;

                fixed4 col = tex2D(_MainTex, i.uv);
				return float4(diffuse, 1.0) * col;
			}
            ENDCG
        }
    }
}
