//Made by Javier Sandoval (lopea) https://github/lopea
//----------------------------------------------------------------------------
//this file is made so it will be easier to have muliple passes 
//and add mulitple lights in our shader
//----------------------------------------------------------------------------

//This should be same shader as the PBR shader in the basic's folder.
#if  !defined(_BASICLIGHT)
#define _BASICLIGHT

#include "UnityPBSLighting.cginc"

sampler2D _MainTex;
float4 _MainTex_ST;
float _Metallic;
float _Smoothness;
float4 _Tint;

//Data coming from CPU
struct appdata {
  float4 vertex : POSITION;
  float2 uv : TEXCOORD0;
  float3 normal : NORMAL;
};

//Output from vertex to fragment
struct v2f {
  float4 vertex : SV_POSITION;
  float2 uv : TEXCOORD0;
  float3 normal : TEXCOORD1;
  float3 worldpos : TEXCOORD2;
};

//Vertex Shader
v2f vert(appdata v)
{
  v2f o;
  o.vertex = UnityObjectToClipPos(v.vertex);
  o.normal = UnityObjectToWorldNormal(v.normal);
  o.worldpos = mul(unity_ObjectToWorld,v.vertex);
  o.uv = TRANSFORM_TEX(v.uv, _MainTex);
  return o;
}

//Fragment Shader
float4 frag(v2f i) : SV_Target
{
  i.normal = normalize(i.normal); 
  float3 viewdir = normalize(_WorldSpaceCameraPos - i.worldpos);
  float3 lightcol = _LightColor0.xyz;
  float3 lightdir = _WorldSpaceLightPos0;
  
  float oneminus;
  float3 specTint;
  float3 albedo = tex2D(_MainTex, i.uv) * _Tint;
  albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specTint, oneminus);

  UnityLight light;
  light.dir = lightdir;
  light.color = lightcol;
  light.ndotl = DotClamped(i.normal, lightdir);

  UnityIndirect indir;  
  indir.diffuse = 0;
  indir.specular = 0;

  return UNITY_BRDF_PBS(albedo, specTint, oneminus, 
    _Smoothness, i.normal, viewdir, light, indir);
}

#endif