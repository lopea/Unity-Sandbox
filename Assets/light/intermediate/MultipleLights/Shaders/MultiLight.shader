Shader "Unlit/MultiLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Metallic ("Metallic", Range(0,0.9)) = 0.5
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
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "BasicLight.cginc"
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One //Blend lights properly.
            ZWrite Off    //Writing to z buffer twice is redundant.
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile_fwdadd
            #include "BasicLight.cginc"
            ENDCG
        }
    }
}
