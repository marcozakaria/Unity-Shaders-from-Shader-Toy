// https://www.shadertoy.com/view/3lGXDd
Shader "Unlit/SpiralColors
"
{
    Properties
    {
        _Speed("Speed Spin",Range(-0.34,0.34)) = 0.1
        _SpeedColor("Color Speed",Range(0,5.0)) = 1.0
        _Scale("Scale",Range(1.0,2.0)) = 1.0
        _Linecount("Line count",Int) = 2
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

            fixed _Scale, _Speed , _SpeedColor;
            int _Linecount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed n21 (fixed2 p) 
            {
                return frac(sin(p.x*124.43 + p.y*5432.)*44433.);
            }

            fixed3 getColorByIndex(fixed id) 
            {
                fixed n = n21(fixed2(id, id));
                fixed3 color = fixed3(sin(n + _Time.y*_SpeedColor), frac(n*10.23), frac(n*453.223));
                return color;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv - 0.5) * _Scale;

                fixed circles = 8.;
                fixed swirl = _Linecount;

                fixed a = atan2(uv.y, uv.x) / 6.28 + .5;

                fixed len = length(uv);

                fixed d = len + _Time.y*_Speed + a/circles * swirl;

                fixed nd = d * circles;

                fixed id = floor(nd);
                fixed df = frac(nd);

                fixed3 color = getColorByIndex(id);
                fixed3 color1 = getColorByIndex(id + swirl);

                color = lerp(color, color1, 1. - a);

                return fixed4(color, 1.);
            }
            ENDCG
        }
    }
}
