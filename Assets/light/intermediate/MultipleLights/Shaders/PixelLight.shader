Shader "Unlit/PixelLight"
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
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_all
            #pragma multi_compile _ VERTEXLIGHT_ON            
            #include "BasicLight.cginc"
            ENDCG
        }
        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_all
            #pragma multi_compile _fwdadd

            #include "BasicLight.cginc"
            ENDCG
        }
    }
}
