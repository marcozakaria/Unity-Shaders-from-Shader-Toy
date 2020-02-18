// https://www.shadertoy.com/view/tt3SDf
Shader "Unlit/SnakeSkine"
{
    Properties
    {
        _Scale("Scale",Range(1,50)) = 10.0
        _Col1("Color 1",Color) = (0.12545, 0.1686, 0.2)
        _Col2("Color 2",Color) = (0.921, 0.945, 0.96)
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

            fixed _Scale;
            fixed3 _Col1, _Col2;    

            #define SF 1. /  _Scale * .5
            #define SS(l, s) smoothstep(SF, -SF, l - s)

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv - 0.5) * _Scale;
                fixed ssf = SF *  .004;

                fixed2 id = floor(uv);
                uv = frac(uv) - 0.5;

                fixed mask = 0.0;
                fixed rmask = 0.0;

                for (int k = 0; k < 9; k++) 
                {
                    fixed2 P = fixed2(k % 3, k / 3) - 1.;
                    fixed2 rid = id - P;
                    fixed2 ruv = uv + P + fixed2(0, fmod(rid.x, 2.) * .5) + fixed2(0, sin(_Time.y * 2. + rid.x * 5. + rid.y * 100.) * .2);

                    fixed l = length(ruv);

                    fixed d = SS(l, .75) * (ruv.y + 1.);

                    mask = max(mask, d);
                    if (d >= mask) 
                    {
                        mask = d;
                        rmask = SS(abs(l - .65), SF * .007);
                    }
                }

                fixed3 col = lerp(_Col1, _Col2, rmask);

                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
