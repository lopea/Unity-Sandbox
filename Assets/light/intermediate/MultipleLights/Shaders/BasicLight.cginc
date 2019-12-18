//Made by Javier Sandoval (lopea) https://github/lopea
//----------------------------------------------------------------------------
//this file is made so it will be easier to have muliple passes 
//and add mulitple lights in our shader
//There is a lot of repitition in this shader, just getting used to the whole
//shading process.
//----------------------------------------------------------------------------

//This should be same shader as the PBR shader in the basic's folder.
#if  !defined(_BASICLIGHT)
#define _BASICLIGHT

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

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
#if VERTEXLIGHT_ON  //if pixel lights are given
  float3 vertexLightColor : TEXCOORD3;
#endif
};

void vertLight(inout v2f i)
{
#if VERTEXLIGHT_ON
  i.vertexLightColor = unity_LightColor[0].rgb;
#endif

}

//Vertex Shader
v2f vert(appdata v)
{
  v2f o;
  o.vertex = UnityObjectToClipPos(v.vertex);
  o.normal = UnityObjectToWorldNormal(v.normal);
  o.worldpos = mul(unity_ObjectToWorld,v.vertex);
  o.uv = TRANSFORM_TEX(v.uv, _MainTex);
  vertLight(o); 
  return o;
}

//Fragment Shader for directional lights only
float4 frag(v2f i) : SV_Target
{
#ifdef DIRECTIONAL
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
#endif
  return 0;
}

UnityLight light(v2f i)
{
  UnityLight l;
#ifndef DIRECTIONAL
  l.dir = normalize(_WorldSpaceLightPos0.rgb - i.worldpos);
#else
  l.dir = _WorldSpaceLightPos0.rgb;
#endif
  UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldpos);
  l.color = _LightColor0.rgb * attenuation;
  l.ndotl = DotClamped(i.normal, l.dir);
  return l;
}


//creates a struct any indirect light directed at the object.
UnityIndirect indir(v2f o)
{
  UnityIndirect i;
  i.diffuse = 0;
  i.specular = 0;
#if VERTEXLIGHT_ON
  float lightvec = (_WorldSpaceLightPos0.rgb - o.worldpos);
  float attenuation = 1 / (1 + dot(lightvec, lightvec) * unity_4LightAtten0.x);
  float ndotl = DotClamped(i.normal, normalize(lightvec));
  i.diffuse = o.vertexLightColor * attenuation * ndotl;
#endif
  return i;
}

//fragment shader for point lights only
float4 frag_point(v2f i) : SV_Target
{
#ifdef POINT
  i.normal = normalize(i.normal);
  float3 viewdir = normalize(_WorldSpaceCameraPos - i.worldpos);

  float3 specTint;
  float oneminus;
  float3 albedo = tex2D(_MainTex, i.uv) * _Tint;
  albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specTint, oneminus);

  return UNITY_BRDF_PBS(albedo, specTint, oneminus,_Smoothness, i.normal, viewdir,light(i), indir(i));
#endif
  return 0;
}

//fragment shader that renders all lights (also used in the vertex light shader.)
float4 frag_all(v2f i) : SV_Target
{
  i.normal = normalize(i.normal);
  float3 viewdir = normalize(_WorldSpaceCameraPos - i.worldpos);

  float oneminus;
  float3 specTint;
  float3 albedo = tex2D(_MainTex, i.uv) * _Tint;
  albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specTint, oneminus);

  return UNITY_BRDF_PBS(albedo, specTint, oneminus,
    _Smoothness, i.normal, viewdir, light(i), indir(i));
}

#endif
