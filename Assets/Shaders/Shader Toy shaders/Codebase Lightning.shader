// https://www.shadertoy.com/view/wltSWn
Shader "Custom/Codebase Lightning"
{

	Properties
	{
      _Iter("Lines Iterations",Range(1,10)) = 2
	}

	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

		Pass
		{
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"

        struct VertexInput
        {
          fixed4 vertex : POSITION;
          fixed2 uv:TEXCOORD0;
        };

        struct VertexOutput 
        {
          fixed4 pos : SV_POSITION;
          fixed2 uv:TEXCOORD0;
        };

        fixed _Iter;

        fixed2 hash (in fixed2 p) 
        {
          p = fixed2 (dot (p, fixed2 (127.1, 311.7)), dot (p, fixed2 (269.5, 183.3)));

          return -1. + 2.*frac (sin (p)*43758.5453123);
        }

        fixed noise (in fixed2 p) 
        {
          const fixed K1 = .366025404;
          const fixed K2 = .211324865;

          fixed2 i = floor (p + (p.x + p.y)*K1);
          
          fixed2 a = p - i + (i.x + i.y)*K2;
          fixed2 o = step (a.yx, a.xy);    
          fixed2 b = a - o + K2;
          fixed2 c = a - 1. + 2.*K2;

          fixed3 h = max (.5 - fixed3 (dot (a, a), dot (b, b), dot (c, c) ), .0);

          fixed3 n = h*h*h*h*fixed3 (dot (a, hash (i + .0)),
                                dot (b, hash (i + o)),
                                dot (c, hash (i + 1.)));

          return dot (n, fixed3 (70.,70.0,70.0));
        }

        fixed fbm(fixed2 pos, fixed tm)
        {
            fixed2 offset = fixed2(cos(tm), 0.0);
            fixed aggr = 0.0;
            
            aggr += noise(pos);
            aggr += noise(pos + offset) * 0.5;
            aggr += noise(pos + offset.yx) * 0.25;
            aggr += noise(pos - offset) * 0.125;
            aggr += noise(pos - offset.yx) * 0.0625;
            
            aggr /= 1.0 + 0.5 + 0.25 + 0.125 + 0.0625;
            
            return (aggr * 0.5) + 0.5;    
        }

        fixed3 lightning(fixed2 pos, fixed offset)
        {
            fixed3 col = fixed3(0.0,0.0,0.0);
            fixed2 f = fixed2(0.0, -_Time.y * 0.5 );
            
            for (int i = 0; i < _Iter; i++)
            {
                fixed time = _Time.y +fixed(i);
                fixed d1 = abs(offset * 0.03 / (0.0 + offset - fbm((pos + f) * 3.0, time)));
                fixed d2 = abs(offset * 0.03 / (0.0 + offset - fbm((pos + f) * 2.0, 0.9 * time + 10.0)));
                col += fixed3(d1 * fixed3(0.1, 0.3, 0.8));
                col += fixed3(d2 * fixed3(0.7, 0.3, 0.5));
            }
            
            return col;
        }

        /*fixed distanceCodebaseAlpha(fixed2 pos)
        {
            return length(pos) -0.25;
        }*/

        VertexOutput vert (VertexInput v)
        {
          VertexOutput o;
          o.pos = UnityObjectToClipPos (v.vertex);
          o.uv = v.uv;
          return o;
        }

        fixed4 frag(VertexOutput i) : SV_Target
        {				
          fixed2 uv = (i.uv -0.5);

          fixed dist = length(uv) - 0.25;
          //fixed dist = distanceCodebaseAlpha(uv);
          
          fixed3 n = lightning(uv, dist + 0.4);
          fixed3 col = fixed3(0.0,0.0,0.0);
          
          col += n;
          col += 0.5 * smoothstep(0.01, -0.01, dist) * sqrt(smoothstep(0.25, -0.5, dist));
          col += 0.25 * smoothstep(0.1, 0.0, dist);
                  
          return fixed4(col, 1.0);
        }

			ENDCG
		}
	}
}
