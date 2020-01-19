Shader "Unlit/Translucency"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tint("Tint Color", Color) = (1,1,1,1)
        _Amount ("Refraction Amount", Range(0,256)) = 1
        _TAmt ("Tint Amount", Range(0, 1)) = 0
        [NoScaleOffset]_NormalMap("Normal Map", 2D) = "black"
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        LOD 100
        Cull Off
        ZWrite Off
        GrabPass{
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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
                float4 screenPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _GrabTexture;
            float4 _GrabTexture_TexelSize;

            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float _Amount;
            float4 _Tint;
            float _TAmt;
                

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.screenPos = ComputeGrabScreenPos(o.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);

                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.normal.xy = tex2D(_NormalMap, i.uv).wy * 2 - 1;
	            i.normal.z = sqrt(1 - saturate(dot(i.normal.xy, i.normal.xy)));
	            i.normal = i.normal.xzy;

                i.normal = normalize(i.normal);
                
                //stolen from Unity's 3.x glass shader
                //(Remember you had to PAY to use certain shader features?)
                //offsets the grab texture to create a refraction effect
                float3 ref = i.normal * abs(i.normal);
                float2 off = i.normal * _Amount * _GrabTexture_TexelSize.xy;
                i.screenPos.xy += off * i.screenPos.z;
                
                // sample the grab Texture
                fixed4 col = tex2Dproj(_GrabTexture, i.screenPos);
                col += _Tint * _TAmt;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //return float4((refract(i.worldDir, i.normal, _Amount)), 1);
                return col;
            }
            ENDCG
        }
        
    }
}
