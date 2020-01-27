// https://www.shadertoy.com/view/llcXW7
Shader "Custom/Foamy Water"
{

	Properties
	{
		//_MainTex ("Texture", 2D) = "white" {}		
		_MAX_ITER("Max iteration",Range(1,32)) = 4
		_TILING_FACTOR("Tiling Factor",Range(0.01,5.0)) = 1.0
		_Speed("Speed",Range(0.01,5.0)) = 0.1
		_DistCenterPower("Dist Center Power",Range(0.1,20.0)) = 2.0
		_Color("Color",Color) = (1,1,1)
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

			// Modified from k-mouse (2016-11-23)
			// Modified from David Hoskins (2013-07-07) and joltz0r (2013-07-04)

			#define TAU 6.28318530718 //6.28318530718

			fixed _TILING_FACTOR;
			fixed _MAX_ITER;
			fixed _Speed;
			fixed _DistCenterPower;
			fixed4 _Color;


			fixed waterHighlight(fixed2 p, fixed time, fixed foaminess)
			{
				fixed2 i = p;
				fixed c = 0.0;
				fixed foaminess_factor = lerp(1.0, 6.0, foaminess);
				fixed inten = .005 * foaminess_factor;

				for (int n = 0; n < _MAX_ITER; n++) 
				{
					fixed t = time * (1.0 - (3.5 / fixed(n+1)));
					i = p + fixed2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
					c += 1.0/length(fixed2(p.x / (sin(i.x+t)), p.y / (cos(i.y+t))));
				}
				c = 0.2 + c / (inten * _MAX_ITER);
				c = 1.17-pow(c, 1.4);
				c = pow(abs(c), 8.0);
				return c / sqrt(foaminess_factor);
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
				
				fixed time = _Time.y * _Speed +23.0;
				
				fixed dist_center = pow(2.0*length(i.uv - 0.5), _DistCenterPower);
				
				fixed foaminess = smoothstep(0.4, 1.8, dist_center);
				fixed clearness = 0.1 + 0.9*smoothstep(0.1, 0.5, dist_center);
				
				fixed2 p = fmod(i.uv*TAU*_TILING_FACTOR, TAU)-250.0;
				
				fixed c = waterHighlight(p, time, foaminess);
				
				fixed3 water_color = fixed3(0.0, 0.35, 0.5);
				fixed3 color = fixed3(c,c,c);
				color = clamp(color + water_color, 0.0, 1.0);
				
				color = lerp(water_color, color, clearness);

				return fixed4(color*_Color.rgb, c * _Color.a);

			}
			ENDCG
		}
	}
}

