Shader "Unlit/Truchet Effect Sqaure"
{
    Properties
    {
        _Width("Line Width",Range(0.001,1.0)) = 0.1
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

            fixed _Width;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed Hash21(fixed2 p) // random number function
            {
                p = frac(p* fixed2(233.32, 851.73));
                p += dot(p, p +23.45);
                return frac(p.x*p.y);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv -0.5) * 10;
                fixed4 col= fixed4(0,0,0,0);

                fixed2 gv = frac(uv) -0.5;
                fixed2 id = floor(uv);

                fixed n = Hash21(id); // random numer to rotate lines
                if(n < 0.5) gv.x *= -1;

                //Draw solid lines rectangles
                fixed d = abs(abs(gv.x + gv.y) - 0.5);
                fixed mask = smoothstep(0.01, -0.01, d- _Width); 

                // draw Circles lines
                /* fixed d = length(gv - sign(gv.x+gv.y)*0.5) - 0.5;
                fixed mask = smoothstep(0.01, -0.01, abs(d)- _Width);  */

                col += mask;

                // debug uv
                //if(gv.x > 0.48 || gv.y > 0.48) col = fixed4(1,0,0,0);
                return col;
            }
            ENDCG
        }
    }
}
