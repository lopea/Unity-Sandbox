Shader "Unlit/LightAll"
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
            CGPROGRAM
            #pragma vertex vert
            #pragma target 3.0
            #pragma fragment frag_all
            #pragma multi_compile_fwdadd
            #include "BasicLight.cginc"
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One 
            ZWrite Off

            CGPROGRAM
           #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag_all
            #pragma multi_compile_fwdadd
            #include "BasicLight.cginc"
            ENDCG
        }
    }
}
