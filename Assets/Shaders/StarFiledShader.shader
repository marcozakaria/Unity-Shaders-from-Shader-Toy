// from art of code
Shader "Unlit/StarFiledShader"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}

        _Scale("Scale",Range(1.0,20.0)) = 5.0
        _FadeVal("Fade length XY", Vector) = (1.2,0.8,0,0)
        _CFSpeed("Circle Fade Speed",Range(0.1,20.0)) = 5.0
        _MoveSpeed("Move Speed",Range(0.1,10.0)) = 1.0
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

           // sampler2D _MainTex;
            //float4 _MainTex_ST;

            fixed _Scale;
            fixed2 _FadeVal;
            fixed _CFSpeed;
            fixed _MoveSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;//TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // a start oint , b end point
            fixed DistLine(fixed2 p , fixed2 a , fixed2 b)
            {
                fixed2 pa = p-a;
                fixed2 ba = b-a;
                fixed t = clamp(dot(pa, ba) / dot(ba, ba), 0.0 , 1.0);
                return length(pa - ba*t);
            }

            fixed N21(fixed2 p ) // random number function
            {
                p = frac(p* fixed2(233.32, 851.73));
                p += dot(p, p +23.45);
                return frac(p.x*p.y);
            }

            fixed2 N22(fixed2 p)
            {
                fixed n = N21(p);
                return fixed2(n, N21(n+p));
            }

            fixed2 GetPos(fixed2 id, fixed2 offset)
            {
                fixed2 n = N22(id+offset) * _Time.y*_MoveSpeed;
                return offset+sin(n)*0.4; // 0.4 to stay inside grid boundry
            }

            fixed Line(fixed2 p , fixed2 a, fixed2 b)
            {
                fixed m = smoothstep(0.03,0.01, DistLine(p, a, b));
                m *= smoothstep(_FadeVal.x,_FadeVal.y,length(a-b));
                return m;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);

                fixed2 uv = (i.uv - 0.5);
                fixed3 col = fixed3(0.0,0.0,0.0);

                //fixed d = DistLine(uv,fixed2(0.0,0.0), fixed2(1.0,1.0));//distance
                fixed m = 0;

                uv *= _Scale;

                fixed2 gv = frac(uv) - 0.5; // grid UV
                fixed2 id = floor(uv);

                fixed2 p[9]; // 3x3 grid

                int iter=0;
                for(fixed y = -1; y <= 1; y++)
                {
                    for(fixed x = -1; x <= 1; x++)
                    {
                        p[iter++] = GetPos(id, fixed2(x,y));
                    }
                }

                fixed time = _Time.y* _CFSpeed;
                for(int iter = 0; iter<9; iter++)
                {
                    m += Line(gv, p[4], p[iter]);

                    fixed2 j = (p[iter]- gv) * 20.0;
                    fixed sparkle = 1.0 / dot(j,j); // dot samething like square

                    m += sparkle * (sin(time + p[iter].x*10)*0.5 + 0.5);
                }
                // draw more 4 lines to avoid overlabing
                m += Line(gv, p[1], p[3]); 
                m += Line(gv, p[1], p[5]);
                m += Line(gv, p[7], p[3]);
                m += Line(gv, p[7], p[5]);

                col = fixed3(m,m,m);

                //col.rg = gv; // to see grid debug
                //if(gv.x > 0.48 || gv.y > 0.48) col = fixed3(1,0,0);
                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
