Shader "Unlit/PBR"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Metallic("Metallic", Range(0,1)) = 0.5
        _Smoothness("Smoothness", Range(0,1)) = 0.5
        _Tint("Tint", Color) = (1,1,1,1)
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

            #include "UnityPBSLighting.cginc"

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
                float3 worldpos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Metallic;
            float _Smoothness;
            float4 _Tint;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldpos = mul(unity_ObjectToWorld,v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //normalize the normal
                i.normal = normalize(i.normal);
                
                //get directions
                float3 lightdir = _WorldSpaceLightPos0.xyz;
                float3 viewdir = normalize(_WorldSpaceCameraPos - i.worldpos);
                
                //
                float3 lightcolor = _LightColor0.rgb;
                
                //setup variables for specular and albedo 
                float3 specTint; 
                float oneminus;
                
                // get albedo value 
                float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
                
                //modify albedo based on metallic values
                albedo =  DiffuseAndSpecularFromMetallic(albedo, _Metallic, specTint, oneminus);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, albedo);
                //setup light values
                UnityLight light; 
                light.color = lightcolor;
                light.dir = lightdir;
                light.ndotl = DotClamped(i.normal, lightdir);
                //no indirect light for now
                UnityIndirect indir;
                indir.diffuse = 0;
                indir.specular = 0;
                
                //apply unity's PBR shader
                return UNITY_BRDF_PBS(albedo,specTint,oneminus,_Smoothness,i.normal, viewdir,light, indir);
            }
            ENDCG
        }
    }
}
