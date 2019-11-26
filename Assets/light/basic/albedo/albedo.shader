Shader "Unlit/albedo"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AlbedoTex("Albedo", 2D) = "white" {}
        _Tint("Albedo Tint", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityStandardBRDF.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _AlbedoTex;
            float4 _MainTex_ST;
            float4 _Tint;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.normal = normalize(i.normal);
                float3 lightdir = _WorldSpaceLightPos0;
                float4 lightcolor = _LightColor0;
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 albedo = tex2D(_AlbedoTex,i.uv) * _Tint;
                float4 diffuse = lightcolor * col * albedo * DotClamped(i.normal,lightdir);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return diffuse;
            }
            ENDCG
        }
    }
}
