Shader "Custom/surface"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _CameraPos("Camera Position", Vector) = (0,0,0,0)
     
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows nolightmap vertex:wave tessellate:tessDistance
        #include "noiseSimplex.cginc"
        #include "Tessellation.cginc"
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Dist;
        float4 _CameraPos;
        float2 _absuv;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        struct appdata {
          float4 vertex : POSITION;
          float4 tangent : TANGENT;
          float3 normal : NORMAL;
          float2 texcoord : TEXCOORD0;
        };
      
        float4 tessDistance() {
          return 20;
        }
        float noise(float2 d, float t)
        {
          float n = 0;
          
          for (int i = 0; i < 4; i++)
          {
            n += snoise(d * (i + 1) + t);
          }
          n -= n * (d.x + 0.5);
          return n;
        }
        float Dist(float3 a, float3 b)
        {
          return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2) + pow(a.z - b.z, 2));
        }
        void wave(inout appdata v) 
        {
          float2 absuv = float2(abs(v.texcoord.x - 0.5), v.texcoord.y);
          v.vertex.xyz += v.normal * noise(absuv, -_Time * 10);
        }
     
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
          float2 absuv = float2(abs(IN.uv_MainTex.x - 0.5), IN.uv_MainTex.y);
          fixed4 c = tex2D (_MainTex,absuv) * noise(absuv, -_Time * 10) * _Color;
          o.Emission = _Color * noise(absuv, -_Time * 10);
          o.Albedo = c.rgb;
          // Metallic and smoothness come from slider variables
          o.Metallic = _Metallic;
          o.Smoothness = _Glossiness;
          o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
