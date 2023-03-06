Shader "Hidden/CharcoalImageEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CharcoalTex("Charcoal", 2D) = "black" {}
        _PaperTex("Paper", 2D) = "bump" {}
        _PaperStrength("Strength", Range(0,1)) = 0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 normUv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _CharcoalTex;
            sampler2D _PaperTex;
            float4 _PaperTex_ST;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normUv = TRANSFORM_TEX(v.uv, _PaperTex);
                return o;
            }

            float _Strength;

            fixed4 frag(v2f i) : SV_Target
            {
                half4 norm = tex2D(_PaperTex, i.normUv);
                norm.z = 0;

                norm = half4(UnpackNormal(norm), 0);
                norm = (norm - 0.5f) * 2;
                norm /= (_ScreenParams.x / 10);
                norm *= _Strength;
                
                fixed4 col = tex2D(_MainTex, i.uv + norm.xy);
                fixed4 charcoal = tex2D(_CharcoalTex, i.uv);
                float lightValue = (0.2126 * col.r) + (0.7152 * col.g) + (0.0722 * col.b);
                
                float level0 = saturate(lightValue * 3);
                float level1 = saturate(lightValue - 0.333f) * 3;
                float level2 = saturate(lightValue - 0.666f) * 3;
                
                float cDark = lerp(charcoal.r, charcoal.g, level0);
                cDark = lerp(cDark, charcoal.b, level1);
                float cLight = lerp(cDark, 1, level2);
                
                float redAmount = sqrt(saturate(col.r - (col.g + col.b)));

                return lerp(float4(cDark, cDark, cDark, 1), col, redAmount);
            }
            ENDCG
        }
    }
}
