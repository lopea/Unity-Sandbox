#pragma once

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

struct appdata
{
    float4 vert : POSITION;
    float2 uv : TEXCOORD0;
    float4 normal : NORMAL;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 normal : TEXCOORD1;
    float4 worldpos : TEXCOORD2;
#if VERTEXLIGHT_ON
    float4 vertexLightColor : TEXCOORD3;
#endif
};

sampler2D _MainTex;
float4 _MainTex_ST;

float4 _Tint;
float4 _Metallic;
float4 _Smoothness;

v2f vert(appdata i)
{
    v2f o;

    o.vert = UnityObjectToClipPos(i.vert);
    o.uv = TRANSFORM_TEX(i.uv, _MainTex);
    o.worldpos = UnityObjectToWorldPos(i.vert);
    o.normal = UnityObjectToWorldNormal(i.normal);
    getPixelLight(o);
}

void getPixelLight(v2f i)
{
#if VERTEXLIGHT_ON
    i.vertexLightColor = Shade4PointLights(
     unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
     unity_LightColor[0].rgb, unity_LightColor[1].rgb,
     unity_LightColor[2].rgb, unity_LightColor[3].rgb,
     unity_4LightAtten0, i.worldpos, i.normal);  
#endif
}

UnityIndirect indir(v2f i)
{
    UnityIndir ind; 
    ind.diffuse = 0;
    ind.specular = 0;
    //calculate light to pixel lights
#if VERTEXLIGHT_ON
    float3 lightvec = normalize(_WorldSpaceLightPos0 - i.worldpos);
    float3 ndotl = DotClamped(i.normal,normalize(lightvec));
    float atten = 1 / (1 + dot(lightvec, lightvec) * unity_4LightAtten0.x);
    ind.diffuse = i.vertexLightColor * atten * ndotl;
#endif

    //calculate spherical harmonics
    ind.diffuse += max(0, ShadeSH9(i.normal, 1));

    return ind;
}

UnityLight light(v2f i)
{
    UnityLight l;
#if DIRECTIONAL
    float3 lightdir = _WorldSpaceLightPos0;
#else
    float3 lightdir = normalize(_WorldSpaceLightPos0 - i.worldpos);
#endif
    //store values into the struct
    l.ndotl = DotClamped(lightDir, i.normal);
    l.col = _LightColor0;
    l.dir = lightdir;
    
    
}

float4 frag(v2f i) : SV_Target
{
  i.normal = normalize(i.normal);

  float4 albedo = tex2D(_MainTex, i.uv) * _Tint;
  float3 viewdir = normalize(_WorldSpaceCameraPos - i.worldpos);

  float3 specTint;
  float oneminus;
  albedo = DiffuseAndSpecularFromDiffuse(albedo, _Metallic, specTint, oneminus);
  
  return UNITY_BDRF_PBS(albedo, specTint, oneminus,
      _Smoothness, i.normal, h)

}

