// https://www.shadertoy.com/view/MltcWl
Shader "Custom/Kaleido Tunnelfmod "
{

	Properties
	{
		_MainTex ("MainTex", 2D) = "white" {}
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
				fixed4 tangent : TANGENT;
				fixed3 normal : NORMAL;
			};


			struct VertexOutput 
			{
				fixed4 pos : SV_POSITION;
				fixed2 uv:TEXCOORD0;
			};

			float4 _iMouse;
			sampler2D _MainTex;

		    // Fork of "Kaleido Tunnel" by zackpudil. https://shadertoy.com/view/XtcXWM
			// 2018-08-19 20:51:34

			fixed time() { return _Time.y; }
			fixed2 resolution() { return 1; }

			fixed hash(fixed n) 
			{
				return frac(sin(n)*43578.5453);
			}

			fixed2x2 rotate(fixed a) 
			{
				fixed s = sin(a);
				fixed c = cos(a);
				
				return fixed2x2(c, s, -s, c);
			}

			fixed de(fixed3 p) 
			{
				fixed3 op = p;
				p = frac(p + 0.5) - 0.5;
				p.xz = mul(p.xz, rotate(3.14159));
				const int it = 7;
				[unroll(100)]
				for(int i = 0; i < it; i++) 
				{
					p = abs(p);
					p.xz = mul(p.xz, rotate(-0.1 + 0.1*sin(time())));
					p.xy = mul(p.xy, rotate(0.3));
					p.yz = mul(p.yz, rotate(0.0 + 0.2*cos(0.45*time())));
					p = 2.0*p - 1.0;
				}
				
				fixed c = length(op.xz - fixed2(0, 0.1*time())) - 0.08;
				
				return max(-c, (length(max(abs(p) - 1.7 + tex2D(_MainTex, fixed2(0,0)).r, 0.0)))*exp2(-fixed(it)));
			}

			fixed trace(fixed3 ro, fixed3 rd, fixed mx)
			 {
				fixed t = 0.0;
				[unroll(100)]
				for(int i = 0; i < 100; i++) 
				{
					fixed d = de(ro + rd*t);
					if(d < 0.001*t || t >= mx) break;
					t += d;
				}
				return t;
			}

			fixed3 normal(fixed3 p)
			 {
				fixed2 h = fixed2(0.001, 0.0);
				fixed3 n = fixed3(
					de(p + h.xyy) - de(p - h.xyy),
					de(p + h.yxy) - de(p - h.yxy),
					de(p + h.yyx) - de(p - h.yyx)
				);
				return normalize(n);
			}

			fixed ao(fixed3 p, fixed3 n)
			 {
				fixed o = 0.0, s = 0.005;
				[unroll(100)]
				for(int i= 0; i < 15; i++)
				{
					fixed d = de(p + n*s);
					o += (s - d);
					s += s/(fixed(i) + 1.0);
				}
				return 1.0 - clamp(o, 0.0, 1.0);
			}

			fixed3 render(fixed3 ro, fixed3 rd) 
			{
				fixed3 col = fixed3(1,1,1);
				
				fixed t = trace(ro, rd, 10.0);
				if(t < 10.0) 
				{
					fixed3 pos = ro + rd*t;
					fixed3 nor = normal(pos);
					fixed3 ref = normalize(reflect(rd, nor));

					fixed occ = ao(pos, nor);
					fixed dom = smoothstep(0.0, 0.3, trace(pos + nor*0.001, ref, 0.3));

					col = 0.1*fixed3(occ,occ,occ);
					col += clamp(1.0 + dot(rd, nor), 0.0, 1.0)*lerp(fixed3(1,1,1), fixed3(1.0, 0.3, 0.3), 1.0 - dom);
					col *= fixed3(0.7, 3.0, 5.0);	
				}
				
				col = lerp(col, fixed3(10,10,10), 1.0 - exp(-0.16*t));
				return col;
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
				fixed2 uv = (-resolution() + 2.0*i.uv)/resolution().y;
				fixed2 mo = _iMouse.z > 0.0 ? (-resolution() + 2.0*_iMouse.xy)/resolution().y : fixed2(0,0);
			
				fixed atime = 0.1*time();
				fixed3 ro = fixed3(0.0, 0.0, atime);    
				fixed3 la = fixed3(2.0*mo, atime + 1.0);
				
				fixed3 ww = normalize(la-ro);
				fixed3 uu = normalize(cross(fixed3(0, 1, 0), ww));
				fixed3 vv = normalize(cross(ww, uu));
				fixed3x3 ca = fixed3x3(uu, vv, ww);
				fixed3 test = mul( ca , fixed3(uv, 1.97));
				fixed3 rd = normalize(test);
				
				fixed3 col = render(ro, rd);
				
				col = 1.0 - exp(-0.4*col);
				col = pow(abs(col), fixed3(1.0/2.2,1.0/2.2,1.0/2.2));
				return fixed4(col, 1);

			}
		ENDCG
		}
    }
}

