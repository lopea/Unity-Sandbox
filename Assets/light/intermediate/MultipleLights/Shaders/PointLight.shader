Shader "Unlit/Pointli"
{
    Properties
    {
       _MainTex("Texture", 2D) = "white" {}
        _Metallic("Metallic", Range(0,0.9)) = 0.5
        _Tint("Tint", Color) = (1,1,1,1)
        _Smoothness("Smoothness", Range(0,0.9)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Blend One One
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_point
            #include "BasicLight.cginc"
            ENDCG
        }
        
        Pass 
        {
            Tags { "LightMode" = "ForwardAdd" }

            Blend One One
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_point
            #pragma multi_compile_fwdadd
            #include "BasicLight.cginc"
            ENDCG
        }
    }
}
