Shader "Unlit/Mountain"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            #include "UnityCG.cginc"
            #include "noiseSimplex.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            float noise(float2 d, float t)
            {
              float n = 0;
          
              for (int i = 0; i < 4; i++)
              {
              n += snoise(d * (i + 1) + float2(0,t));
              }
             
               
              n *= (d.x)* 1;
              return n;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);    
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.x = abs(o.uv.x - 0.5);
                o.vertex += v.normal * noise(o.uv, _Time.y);
    
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col += noise(i.uv, _Time.y) - ((i.uv.x));
                col = 1-col;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
