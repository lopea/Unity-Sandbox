//Metallic.shader by Javier Sandoval (https://github.com/lopea)
Shader "Unlit/Metallic"
{
    Properties
    {
        _Albedo ("Texture", 2D) = "white" {}
        _Smoothness("Smoothness", Range(0,1)) = 1
        _Metallic("Metallic", Range(0,1)) = 1
        _Tint ("Tint",Color) =(1,1,1,1)
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
            #include "UnityStandardUtils.cginc"
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

            sampler2D _Albedo;
            float4 _Albedo_ST;
            float _Smoothness;
            float _Metallic;
            float4 _Tint;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _Albedo);
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
                float4 lightdir = _WorldSpaceLightPos0;

                //get the view direction 
                float3 viewdir = normalize(_WorldSpaceCameraPos - i.worldPos);
                
                //get half normal instead of reflection to fit blinn-phong standard
                float3 halfnormal = normalize(lightdir + viewdir);

                float3 specTint;
                float oneminus;
                float3 albedo = tex2D(_Albedo, i.uv).rgb * _Tint.rgb;
                albedo = DiffuseAndSpecularFromMetallic(albedo,_Metallic,specTint, oneminus);
                
                //set specular lighting by getting the dot product of reflection and viewdir
                float3 specular = specTint * _LightColor0 * pow(DotClamped(halfnormal, i.normal), _Smoothness * 100);
                
                float3 diffuse = albedo * _Tint *_LightColor0 * DotClamped(lightdir, i.normal); 
                //add specular color to the object
                return float4(specular + diffuse, 1.0);
            }
            ENDCG
        }
    }
}
