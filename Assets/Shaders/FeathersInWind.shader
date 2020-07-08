Shader "Custom/FeathersInWind"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}

        _Speed("Speed",Range(0.01,5.0)) = 1.0
        _Scale("Scale",Range(1.0,10.0)) = 1.0

        [Header(Feather Properties)]
        _Strandcount("Strand count", float) = 50.0
        _waveLength("wave Length", float) = 0.2
        _XCutRange("XCutRange", float) = 0.9

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed _Speed, _Scale, _Strandcount, _waveLength, _XCutRange;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float2x2 Rotate(float angle)
            {
                Float s = sin(angle), c = cos(angle);
                return float2x2(c, -s, s, c);
            }

            fixed Feather(fixed2 p)
            {
                fixed d = length(p - fixed2(0, clamp(p.y, -0.3, 0.3))); 
                fixed r = lerp(0.1, 0.0, smoothstep(-0.3, 0.3, p.y));
                fixed m = smoothstep(0.01, 0.0, d-r);

                fixed x = _XCutRange*abs(p.x) / r;
                fixed wave = (1.0 - x) * sqrt(x) + x*(1.0 - sqrt(1.0 - x));
                fixed y = (p.y - wave *_waveLength) * _Strandcount;
                fixed id = floor(y);
                fixed n = frac(sin(id*564.32) * 763.0);  // random number
                fixed shade = lerp(0.3, 1.0 , n);
                fixed strandLength = lerp(0.7, 1.0, frac(n*10.23));

                fixed strand = smoothstep(0.1,0.0, abs(frac(y) - 0.5) - 0.3);
                strand *= smoothstep(0.1, 0.0, x - strandLength);

                d = length(p - fixed2(0, clamp(p.y, -0.45, 0.1))); 
                fixed stem = smoothstep(0.01, 0.0 , d + p.y*0.025);

                return max( m * strand * shade, stem);
            }

            fixed2 BendUV(fixed2 uv)    // old bending in 2d mode
            {
                uv -= fixed2(0, -0.45);
                fixed d = length(uv);
                uv = mul(uv, Rotate(sin(_Time.y * _Speed) * d));
                uv += fixed2(0, -0.45);
                return uv;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv - 0.5) *_Scale;

                fixed4 col = fixed4(0.0,0.0,0.0,1.0);

                uv = BendUV(uv);

                col += Feather(uv);

                return col;
            }

            ENDCG
        }
    }
}
