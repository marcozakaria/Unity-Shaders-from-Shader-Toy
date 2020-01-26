// in spired by https://www.shadertoy.com/view/3lyGRd
Shader "Unlit/FlagShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _ColorA("Color top", Color) = (1.0, 0.0, 0.0)
        _ColorB("Color bottom", Color) = (0.0, 0.0, 0.0)
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

            #include "UnityCG.cginc"

            #define PI 3.1415926535

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

            fixed3 _ColorA;
            fixed3 _ColorB;

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
                fixed4 colTex = tex2D(_MainTex, i.uv);

                fixed2 uv = 2*i.uv -1;
                fixed2 st = i.uv /1;

                float w = sin((uv.x + uv.y - _Time.y * .75 + sin(1.5 * uv.x + 4.5 * uv.y) * PI * .3)
                            * PI * .6); // fake waviness factor
                
                uv *= 1. + (.036 - .036 * w);
                fixed3 col = colTex.rgb;
                
                // flag colors
                col = lerp(col, _ColorA, smoothstep(.35, .36, uv.y));
                col = lerp(col, _ColorB, smoothstep(-.35, -.36, uv.y));
                
                col += w * .225; // for waving effect
                
                float v = 16. * st.x * (1. - st.x) * st.y * (1. - st.y); // vignette
                col *= 1. - .6 * exp2(-1.75 * v);
                
                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
