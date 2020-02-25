// https://www.shadertoy.com/view/ttVSDR
Shader "Unlit/CMUAnimatedCurves"
{
    Properties
    {
        _Scale("Scale",Range(1.0,8.0)) = 3.0
        _Speed("Speed",Range(0.1,10.0)) = 0.5
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

            fixed _Scale, _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed fbm(fixed x) // fractional broinian motion
            {
                fixed sum = 0.0;
                for (fixed i = 1.0; i <= 4.0; i *= 1.7)
                {
                    sum += sin(x * i) / i;
                }
                return sum * 0.4;
            }

            fixed FadeWave(fixed2 uv, fixed pixelSize)
            {
                //gradient borders
                fixed firstSin = fbm(uv.x * 2.0 + _Time.y * _Speed);
                fixed secondSin = fbm(uv.x * 1.2 + 16.3 + _Time.y * _Speed);
                
                //gradient from firstSin to secondSin
                fixed shape = 0.0;
                if (firstSin < secondSin && uv.y < secondSin || secondSin < firstSin && uv.y > secondSin)
                    shape = smoothstep(firstSin, secondSin, uv.y);
                    
                //gradient roundness
                shape = pow(shape, 4.0);
                
                //wave details for antialiasing
                fixed border = 1.0 - smoothstep(0.0, 2.0 * pixelSize, abs(uv.y - secondSin));
                fixed border2 = 1.0 - smoothstep(0.0, 3.0 * pixelSize, abs(uv.y - secondSin));
                
                //adding gradient and details
                fixed fadeWave = clamp(border * 1.0 + shape * 1.0, 0.0, 1.0) + border2 * 0.6;
                return fadeWave;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv-0.5) * _Scale;
                float pixelSize = ddy(uv.y);
                
                //waves design
                float wave1 = FadeWave(uv, pixelSize);
                float wave2 = FadeWave(uv * fixed2(1.2, 1.0) + fixed2(11.2, -0.0), pixelSize);
                float wave3 = FadeWave(uv * fixed2(0.8, 1.0) + fixed2(32.321, 0.0), pixelSize);
                float wave4 = FadeWave(uv * fixed2(0.6, 0.5) + fixed2(22.321, 0.0), pixelSize);
                
                //colors
                fixed4 color = wave1 * fixed4(0.4, 0.9, 0.9, 1.0);
                color += wave2 * fixed4(0.9, 0.4, 0.9, 1.0); 
                color += wave3 * fixed4(0.9, 0.9, 0.4, 1.0);
                color += wave4 * fixed4(0.9, 0.2, 0.6, 1.0);
                
                //postprocess
                color = pow(color, fixed4(0.7,0.7,0.7,0.7));
                color = smoothstep(-0.3, 1.2, color);
                
                return color;
            }
            ENDCG
        }
    }
}
