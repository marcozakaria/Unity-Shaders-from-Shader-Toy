// https://www.shadertoy.com/view/3lcXzN
Shader "Unlit/TwoCirclesShader"
{
    Properties
    {
        _Speed("Speed",Range(0.01,10.0)) = 0.5
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

            #define R_BIG 0.43
            #define R_MIDDLE 0.2
            #define R_SMALL 0.05
            #define MID_CENTER fixed2(0.0, R_MIDDLE)
            #define EPS 0.001

            fixed _Speed;

            float2x2 Rot(float a) 
            {
                float s = sin(a);
                float c = cos(a);
                return float2x2(c, -s, s, c);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = mul(i.uv - 0.5, Rot(_Time.y * _Speed));

                float big = smoothstep(R_BIG, R_BIG - EPS, length(uv));
                float smallUp = smoothstep(R_SMALL, R_SMALL - EPS, length(uv - MID_CENTER));
                float smallDown = smoothstep(R_SMALL, R_SMALL - EPS, length(uv + MID_CENTER));
                float middleUp = smoothstep(R_MIDDLE, R_MIDDLE - EPS, length(uv - MID_CENTER));
                float middleDown = smoothstep(R_MIDDLE, R_MIDDLE - EPS, length(uv + MID_CENTER));
                
                float light = smoothstep(R_MIDDLE * 2. + EPS, R_MIDDLE * 2., length(uv));
                
                light -= middleUp + smallDown + middleDown;
                light *= step(0.0, -uv.x);
                light += middleDown - smallDown;
                light += smallUp;
                
                fixed3 col = fixed3(1.0,1.0,1.0);
                //col += light;
                col *= (1.0 - big + light);

                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
