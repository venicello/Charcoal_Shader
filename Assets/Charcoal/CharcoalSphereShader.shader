Shader "Unlit/CharcoalSphereShader"
{
    Properties
    {
        _MainTex ("100% Texture", 2D) = "black" {}
        _Tex2("66% Texture", 2D) = "white" {}
        _Tex3("33% Texture", 2D) = "white" {}
        _MaskDark("Dark Mask", Color) = (1,0,0,0)
        _MaskMid("Dark Mask", Color) = (0,1,0,0)
        _MaskLight("Light Mask", Color) = (0,0,1,0)
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Tex2;
            sampler2D _Tex3;
            float4 _MaskDark;
            float4 _MaskMid;
            float4 _MaskLight;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 dark = tex2D(_MainTex, i.uv) * _MaskDark;
                float4 midLow = tex2D(_Tex2, i.uv) * _MaskMid;
                float4 midHigh = tex2D(_Tex3, i.uv) * _MaskLight;
                // apply fog
                float4 outFloat = dark + midLow + midHigh;
                return float4(outFloat.rgb, 1);
            }
            ENDCG
        }
    }
}
