//https://www.shadertoy.com/view/wtKGzD
Shader "Custom/Tooth Pick cover"
{
	Properties
	{
		_Iteration("Iteration",Range(2,256)) = 128
		_Speed("Speed",Range(0.1,10.0)) = 4.0
		_Size("Size",Range(1.0,5.0)) = 3.0
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

			fixed _Iteration;
			fixed _Speed;
			fixed _Size;

			#define PI 3.1415

			fixed2 rotate(fixed2 v, fixed a) 
			{
				fixed s = sin(a);
				fixed c = cos(a);
				fixed2x2 m = fixed2x2(c, -s, s, c);
				return mul(m , v);
			}

			VertexOutput vert (VertexInput v)
			{
				VertexOutput o;
				o.pos = UnityObjectToClipPos (v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(VertexOutput i) : SV_Target
			{			
				fixed2 uv =  (i.uv-0.5 * 1)/1;
			
				fixed3 col = fixed3(0,0,0);
				
				fixed time = (_Time.y*_Speed);					
				
				fixed2 cv = uv/_Size;
				cv *= log(time / 2. + 3.);
				cv = rotate(cv, PI/4.);
				cv.y = abs(cv.y);
				cv.x = abs(cv.x);
				fixed rot = 0.;
				
				fixed iter = _Iteration;
				fixed2 id;
				
				[unroll(100)]
				for(fixed i = 2.; i < iter; i *= 2.) 
				{
					fixed size = i;
					id = (floor(cv * size) + fixed2(0.5,0.5));

					fixed a = PI * (floor(1. * sin(id.y*2.2)) + floor(1. * cos(id.x*2.)))/(2.);
					rot += a;
					cv = rotate(cv - id/size, a) + id/size;
				
				}
				id = (floor(cv * iter))/iter;
				
				float width = log(time / 2. + 3.)/4.;
				//float width = 0.2;

				float rv = (cv.x - id.x) * iter;
				//float line =0;
				float linee = smoothstep(0.5 - width, 0.5, rv) * smoothstep(0.5 + width, 0.5, rv);

				//linee *= 1. - step(sin(time / 2. + id.y * 4. + id.x * 4.) * 0.5 + 0.5, cv.y);
				float len = cv.x * iter + cv.y * iter;
				len *= -1.;
				len += (sin(time/8.)* 0.5 + 0.5) * iter;
				
				linee *= smoothstep( len, len - 0.02, cv.y);
				col = float3(linee,linee,linee);
				col.rg *= 0.2 + sin(cv * 24.)/4. + cos(uv*12.)/4.;

				return fixed4(col,linee);
			}
			ENDCG
		}
  }
}

