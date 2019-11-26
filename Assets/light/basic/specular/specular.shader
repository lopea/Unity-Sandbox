Shader "Unlit/Specular"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Smoothness("Smoothness", Range(0,1)) = 1
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
                float4 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Smoothness;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //normalize normal before using it
                i.normal = normalize(i.normal);
                
                //get the directional light in the scene
                float4 lightpos = _WorldSpaceLightPos0;

                //get the view direction 
                float3 viewdir = normalize(_WorldSpaceCameraPos - i.worldPos);

                //get the reflection of light when bounced off object
                float3 reflectdir = reflect(-lightpos,i.normal);

                //set specular lighting by getting the dot product of reflection and viewdir
                float3 specular = pow(DotClamped(viewdir, reflectdir), _Smoothness * 100);
                
                specular *= _LightColor0;
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return float4(specular, 1.0);
            }
            ENDCG
        }
    }
}
