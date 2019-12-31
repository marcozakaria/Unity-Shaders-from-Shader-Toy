// https://www.shadertoy.com/view/tl33Wj
Shader "Custom/Color waves"
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
					
			#define time _Time.y

			fixed cube(fixed3 p, fixed3 s)
			{
				fixed v = 0.78; 
				p.xy = mul(p.xy, fixed2x2(cos(v),-sin(v),sin(v),cos(v)) );
				fixed3 q = frac(p)*2.0 -1.0;
				return length(max(abs(q)-s,0.0));
			}
				
			fixed trace(fixed3 o, fixed3 r)
			{
				fixed t =0.0;
				[unroll(100)]
				for(int i = 0; i < 100;i++)
				{
					fixed3 p = o+r*t;
					fixed d = cube(p-fixed3(-2,0.5,0),fixed3(0.01,0.05,3));
					t += d * 0.25;         
				}
				return t;
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
				fixed2 uv = fixed2(i.uv.x/1,i.uv.y/1);
				uv -= 0.5;
				uv /= fixed2(1/1,1.0);
				uv.y *= (sin(5.0*uv.y+ time)*0.5+0.5)/5.0;
				fixed3 r = normalize(fixed3(uv,1.0)); 
				r.xy = mul(r.xy, fixed2x2(cos(0.79),-sin(0.79),sin(0.79),cos(0.79)) );
				fixed3 o = fixed3(-0.75,0,0);
				fixed t = trace(o,r);
				
				fixed3 col = 0.5 + 0.5*cos(_Time.y+uv.xyx+fixed3(0,2,4));
				fixed fog = 1.0/(1.0+t*t*0.01);

				return fixed4(fixed3(fog*col),1.0);
			}
			ENDCG
		}
   }
}

