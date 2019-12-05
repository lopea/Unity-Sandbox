//BitDepth.shader
//Made by Javier Sandoval (lopea)
//https://github.com/lopea
Shader "Lopea/BitDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Depth ("Depth", Range(2, 256)) = 256
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            float ffloor(float a, float offset)
            {
              return a - (a % offset);
            }

            sampler2D _MainTex;
            float _Depth;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply bit depth
                col.r = (_Depth != 0) ? ffloor(col.r, 1/(_Depth)) : 0; 
                col.g = (_Depth != 0) ? ffloor(col.g, 1/(_Depth)) : 0; 
                col.b = (_Depth != 0) ? ffloor(col.b, 1/(_Depth)) : 0; 
                
                //grayscale if necessary 
                col.rgb = (_Depth > 2) ? col.rgb : saturate(floor((float3)(col.r+col.g+col.b)));

                return col;
            }
            ENDCG
        }
    }
}
