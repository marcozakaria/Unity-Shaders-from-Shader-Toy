// https://www.shadertoy.com/view/WdsyRM
Shader "Unlit/ColorLineWaves1"
{
	Properties
	{
		
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

			static fixed TAU = 6.2831853071;

			static fixed ANGLE = -0.785;
			static fixed2x2 ROTATION = fixed2x2(cos(ANGLE), -sin(ANGLE), sin(ANGLE), cos(ANGLE));

			static fixed SEGMENT_THICKNESS = 0.45;
			static fixed2 SEGMENT_ASPECT = fixed2(8.0, 1.0);

			static fixed2 BOX_SIZE = fixed2(0.333,0.333);
			static fixed BOX_THICKNESS = 0.004;

			static fixed ZOOM = 35.0;

			static fixed3 COLORS[6] = (
				fixed3(0.572, 0.153, 0.561),
				fixed3(0.071, 0.659, 0.616),
				fixed3(0.145, 0.666, 0.886),
				fixed3(0.969, 0.580, 0.114),
				fixed3(0.945, 0.349, 0.165),
				fixed3(0.980, 0.702, 0.576)
			);

			static fixed3 BG_START = fixed3(0.322, 0.301, 0.616);
			static fixed3 BG_END = fixed3(0.980, 0.718, 0.418);

			// https://thebookofshaders.com/10/
			fixed random(fixed2 st) {
				return frac(sin(dot(st.xy, fixed2(12.9898, 78.233))) * 43758.5453123);
			}

			fixed3 segmentColor(fixed2 st) {
				return COLORS[int(random(st) * fixed(COLORS.length()))];
			}

			// https://iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm
			fixed sdSegment(in fixed2 p, in fixed2 a, in fixed2 b) {
				fixed2 pa = p - a, ba = b - a;
				fixed h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
				return length(pa - ba * h);
			}

			fixed sdBox(in fixed2 p, in fixed2 b) {
				fixed2 d = abs(p) - b;
				return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
			}
     
			v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{  
				fixed2 uv = (i.uv - 0.5 * 1) / 1;
				
				fixed boxD = sdBox(uv, BOX_SIZE);
				
				fixed3 col = fixed3(lerp(BG_START, BG_END, uv.y + 0.5));
					
				uv *= ROTATION;
				
				fixed light = uv.x;
				fixed2 id = floor(uv * ZOOM);
				
				// fmodulate x position for each row, fastest nearest to the center
				uv.x += -_Time.y * (0.5-abs(id.y * 0.01)) + random(id.yy) * 0.15;
				
				uv /= SEGMENT_ASPECT;
				uv *= ZOOM;
				
				fixed2 gv = frac(uv);
				
				// comment this out for glitchy colours...
				id = floor(uv);
				
				gv -= 0.5;
				gv *= SEGMENT_ASPECT;
				
				// fmodulate segment length
				fixed segmentLen = 2.0 + sin(_Time.y * (1.5 + random(id) * 1.5) + random(id) * TAU) * random(id) * 1.5;
				
				fixed segmentD = sdSegment(gv, fixed2(-segmentLen, 0.0), fixed2(segmentLen, 0.0)) - SEGMENT_THICKNESS;
					
				// i'm sure this can be done without branching somehow
				if (segmentD > -SEGMENT_THICKNESS && segmentD < -0.05 && boxD < 0.0) 
				{
					col = smoothstep(-0.01, -0.05, segmentD) * segmentColor(id);
					col += light;
				}
				
				col += smoothstep(0.00, -0.001, abs(boxD) - BOX_THICKNESS);
				
				return fixed4(col, 1.0);   
			}
			ENDCG
		}
	}
}

