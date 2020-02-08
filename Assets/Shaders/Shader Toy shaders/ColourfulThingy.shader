// https://www.shadertoy.com/view/WlcSD7
Shader "Unlit/ColourfulThingy"
{
    Properties
    {
        _Speed("Speed",Range(0.01,5.0)) = 1.0
        _Xmul("X Multiplier",Range(0.01,100)) = 20
        _Ymul("Y Multiplier",Range(0.001,1.0)) = 0.05
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

            #define PI 3.14159
            #define tau 6.28318

            fixed _Speed;
            fixed _Xmul, _Ymul;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = i.uv - 0.5;
                fixed2 st = fixed2(atan2(uv.y, uv.x), length(uv));
                uv = fixed2(.5 + st.x / tau, st.y);

                fixed t = _Time.y*_Speed, x, y, m;
                fixed3 col;
                
                for(int i = 0; i < 3; i++) 
                {
                    x = uv.x;
                    y = uv.y  + sin(uv.x * tau * 10. + t) * _Ymul;
                    x *= _Xmul;
                    m = min(frac(x), frac(1.-x));
                    col[i] = smoothstep(0., .1, .25 + m * .3 - y);
                    t+= 1.;
                }
                
                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
