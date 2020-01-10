// https://www.shadertoy.com/view/tlG3WR
Shader "Custom/James bond rabbit hole"
{
	Properties
	{
	
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

			VertexOutput vert (VertexInput v)
			{
				VertexOutput o;
				o.pos = UnityObjectToClipPos (v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(VertexOutput i) : SV_Target
			{			
				// Normalized pixel coordinates (from 0 to 1)
				fixed2 uv = (i.uv-.5 * 1)/1;
				fixed t = _Time.y * .2;
				//uv *= fixed2x2(cos(t),-sin(t),sin(t),cos(t));
				fixed3 ro = fixed3(0, 0, -1);
				fixed3 lookat  = lerp(fixed3(0,0,0),fixed3(-1,0,-1),sin(t*1.56)*.5+.5);
				fixed zoom = lerp(.2,.7,sin(t)*.5+.5);
				
				fixed3 f = normalize(lookat-ro),
					r = normalize(cross(fixed3(0,1,0), f)),
					u = cross(f,r),
					c = ro + f * zoom,
					ii = c + uv.x * r + uv.y * u,
					rd = normalize(ii-ro);
								
				fixed radius = .7;
				fixed d5, dO = 0.0;
				fixed3 p;
								
				[unroll(100)]
				for(int i = 0; i<100; i++)
				{
					p = ro + mul(rd , dO);
					d5 = -(length(fixed2(length(p.xz)-1.,p.y)) - radius);
					if (d5<.001) break;
					dO += d5;				
				}

				fixed3 col = fixed3(0,0,0);

				if(d5<.001) {
				float x = atan2(p.z,p.x)+t*lerp(.4,.8,sin(t)*.01+.5);
				float y = atan2(p.y,length(p.xz)-1.);
				
					float bands = sin(y*10.+x*20.);
					float ripples = sin((x*10.-y*30.)*3.)*.5+.5;
					float waves = sin(x*2.-y*6.+t*10.);
					
				float b1 = smoothstep(-.2,.2, bands);
				float b2 = smoothstep(-.2,.2, bands-.5);
					
					float m = b1*(1.-b2);
					m = max(m, ripples*b2*b2*max(0.,waves));
					m += max(0.,waves*.3*b2);
					
					col+= lerp(m, 1.-m,smoothstep(-.3,.3, sin(x*2.+t)));
			
				col.rg += uv.xy;}
				return fixed4(col,1.0);
				col.rg = uv;
			}
			ENDCG
		}
	}
}

