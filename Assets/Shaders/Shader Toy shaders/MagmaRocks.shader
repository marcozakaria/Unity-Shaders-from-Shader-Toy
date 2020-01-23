//https://www.shadertoy.com/view/4lXfR7
Shader "Custom/Magma Rocks"
{

	Properties
	{
		_Speed("Speed A",Range(0.0,1.0)) = 0.35
		_SpeedB("Speed B",Range(0.0,2.0)) = 0.35

		_ScaleX("Scale X", Float) = 1.0
		_ScaleY("Scale Y", Float) = 1.0
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

			fixed _Speed;
			fixed _SpeedB;
			fixed _ScaleY;
			fixed _ScaleX;

			// random2 function by Patricio Gonzalez
			fixed2 random2( fixed2 p )
			{
				return frac(sin(fixed2(dot(p,fixed2(127.1,311.7)),dot(p,fixed2(269.5,183.3))))*43758.5453);
			}

			// Value Noise by Inigo Quilez - iq/2013
			// https://www.shadertoy.com/view/lsf3WH
			fixed noise(fixed2 st)
			{
				fixed2 i = floor(st);
				fixed2 f = frac(st);

				fixed2 u = f*f*(3.0-2.0*f);

				return lerp( lerp( dot( random2(i + fixed2(0.0,0.0) ), f - fixed2(0.0,0.0) ), 
								dot( random2(i + fixed2(1.0,0.0) ), f - fixed2(1.0,0.0) ), u.x),
							lerp( dot( random2(i + fixed2(0.0,1.0) ), f - fixed2(0.0,1.0) ), 
								dot( random2(i + fixed2(1.0,1.0) ), f - fixed2(1.0,1.0) ), u.x), u.y);
			}

			fixed3 magmaFunc(fixed3 color, fixed2 uv, fixed detail, fixed power,
						fixed colorMul, fixed glowRate, bool animate, fixed noiseAmount)
			{
				//fixed rockColorSingle = vec3(0.09 + abs(sin(iTime * .75)) * .03, 0.02, .02);
				fixed3 rockColor = fixed3(0.09 + abs(sin(_Time.y * _SpeedB)) * .03, 0.02, .02);
				fixed minDistance = 1.;
				uv *= detail;
				
				fixed2 cell = floor(uv);
				fixed2 fraction = frac(uv);
				
				for (int i = -1; i <= 1; i++) 
				{
					for (int j = -1; j <= 1; j++)
					 {
						fixed2 cellDir = fixed2(fixed(i), fixed(j));
						fixed2 randPoint = random2(cell + cellDir);
						randPoint += noise(uv) * noiseAmount;
						randPoint = animate ? 0.5 + 0.5 * sin(_Time.y * _Speed + 6.2831 * randPoint) : randPoint;
						minDistance = min(minDistance, length(cellDir + randPoint - fraction));
					}
				}
					
				fixed powAdd = sin(uv.x * 2. + _Time.y * glowRate) + sin(uv.y * 2. + _Time.y * glowRate);
				fixed3 outColor = fixed3(color * pow(minDistance, power + powAdd * .95) * colorMul);
				outColor.rgb = lerp(rockColor, outColor.rgb, minDistance);
				return outColor;
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
				fixed3 fragColor = fixed3(0.0,0.0,0.0);
				fixed2 uv = i.uv ;
				uv *= fixed2(_ScaleX,_ScaleY);
				uv.x += _Time.y * .01;
				//return fixed3(0.,0.,0.,0.);
				fragColor.rgb += magmaFunc(fixed3(1.5, .45, 0.), uv, 3.,  2.5, 1.15, 1.5, false, 1.5);
				fragColor.rgb += magmaFunc(fixed3(1.5, 0., 0.), uv, 6., 3., .4, 1., false, 0.);
				fragColor.rgb += magmaFunc(fixed3(1.2, .4, 0.), uv, 8., 4., .2, 1.9, true, 0.5);

				return fixed4(fragColor,1.0);
			}

			ENDCG
		}
	  }
}

