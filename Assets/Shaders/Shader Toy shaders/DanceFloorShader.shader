// https://www.shadertoy.com/view/lsBXDW
Shader "Unlit/DanceFloorShader"
{
    Properties
    {
        _Size("Size",Range(2.0,15.0)) = 5.0
        _Speed("Speed",Range(0.1,5.0)) = 1.0
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

            fixed _Speed;
            fixed _Size;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed3 hsv2rgb (fixed3 hsv) 
            {
                hsv.yz = clamp (hsv.yz, 0.0, 1.0);
                return hsv.z * (1.0 + 0.5 * hsv.y * (cos (2.0 * 3.14159 * (hsv.x + fixed3(0.0, 2.0 / 3.0, 1.0 / 3.0))) - 1.0));
            }

            fixed rand (fixed2 seed) 
            {
                return frac(sin (dot (seed, fixed2(12.9898, 78.233))) * 137.5453);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;

                fixed2 frag = (2.0 * i.uv- _ScreenParams.xy);
                frag *= 1.0 - 0.2 * cos (frag.yx) * sin (3.14159 );
                frag *= _Size;
                fixed random = rand (floor (frag));
                fixed2 black = smoothstep (1.0, 0.8, cos (frag * 3.14159 * 2.0));
                fixed3 color = hsv2rgb (fixed3(random, 1.0, 1.0));
                color *= black.x * black.y * smoothstep (1.0, 0.0, length (frac(frag) - 0.5));
                color *= 0.5 + 0.5 * cos(random + random * _Time.y*_Speed + _Time.y*_Speed + 3.14159  );
                col = fixed4 (color, 1.0);

                return col;
            }
            ENDCG
        }
    }
}
