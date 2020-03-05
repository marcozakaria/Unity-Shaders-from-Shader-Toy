Shader "Unlit/HexagonalTiling"
{
    Properties
    {
        _Speed("Speed",Range(0.0,10.0)) = 1.0
        _Scale("Scale",Range(0.0,25.0)) = 5.0
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

            fixed  HexDist(fixed2  p)
            {
                p = abs(p);
                fixed c = dot(p, normalize(fixed2(1,1.73)));
                c = max(c , p.x);

                return c;
            }

            fixed4 HexCoords(fixed2 uv) // return uv + id
            {
                fixed2 r = fixed2(1, 1.73); // 1.732 = squareRoot(3)
                fixed2 h = r*.5;
                 
                fixed2 a = fmod(uv, r) - h;
                fixed2 b = fmod(uv - h, r) - h;

                fixed2 gv =  dot(a,a) < dot(b,b) ? a:b;  // grid UV , dot(a,a) = length(a)

                fixed x = atan2(gv.y,gv.x);
                fixed y = HexDist(gv);
                fixed2 id = uv - gv;
                return fixed4(x, y, id.x, id.y); 
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv ) * _Scale;
                fixed3 col = fixed3(0,0,0);

                fixed4 hc = HexCoords(uv);
                fixed c = smoothstep(0.05,0.03, hc.y*sin(hc.z*hc.w + _Time.y ));
                col +=  c;

                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
