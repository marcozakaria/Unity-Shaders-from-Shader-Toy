//https://www.shadertoy.com/view/ttVGDh
Shader "Custom/Colourful Waves"
{

	Properties
	{
		_Speed("Color Speed" ,Range(0.0,1.0)) = 0.02
		_WaveSpeed("Wave Speed" ,Range(-1.0,1.0)) = 0.1
		_WavesNumber("Waves number" ,Range(0.1,20.0)) = 8.0

		_ColorModifierX("Color modifier X",Range(0.0,2.0)) = 0.12
		_ColorModifierY("Color modifier Y",Range(0.0,2.0)) = 0.2

		_ColorPaletteA("Color Palette A", Color) = (0.5, 0.5, 0.5)
		_ColorPaletteB("Color Palette B", Color) = (0.5, 0.5, 0.5)
		_ColorPaletteC("Color Palette C", Color) = (2., 1., 0.)
		_ColorPaletteD("Color Palette D", Color) = (0.5, 0.2, 0.25)
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
			fixed _WaveSpeed;
			int _WavesNumber;

			fixed _ColorModifierX;
			fixed _ColorModifierY;

			fixed3 _ColorPaletteA;
			fixed3 _ColorPaletteB;
			fixed3 _ColorPaletteC;
			fixed3 _ColorPaletteD;

			#define PI 3.14159265359

			fixed wavePosition(fixed2 uv, fixed i) 
			{
				return sin((uv.x + i * 8.456) * (sin(_Time.y * _WaveSpeed + 7.539 + i * 0.139) + 2.) * 0.5) * 0.65
					+ sin(uv.x * (sin(_Time.y * _WaveSpeed + i * 0.2) + 2.) * 0.3) * 0.3
					- (i - _WavesNumber / 2.) * 2. - uv.y;
			}

			// http://iquilezles.org/www/articles/palettes/palettes.htm
			fixed3 colorPalette(fixed t, fixed3 a, fixed3 b, fixed3 c, fixed3 d) 
			{
				return a + b * cos(PI * 2. * (c * t + d));
			}

			fixed3 color(fixed x) 
			{
				return colorPalette(x, _ColorPaletteA, _ColorPaletteB, _ColorPaletteC, _ColorPaletteD);
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
			
				fixed4 fragColor = 0;
				fixed2 uv = i.uv;

				fixed2 waveUv = (2.0 * i.uv - 1) / 1 * (_WavesNumber - 1.);

				fixed aa = _WavesNumber * 2. / _ScreenParams.y;

				for (fixed i = 0.; i < _WavesNumber; i++)
				{
					fixed waveTop = wavePosition(waveUv, i);
					fixed waveBottom = wavePosition(waveUv, i + 1.);

					fixed3 col = color(i * _ColorModifierX + uv.x * _ColorModifierY + _Time.y * _Speed);

					col += smoothstep(0.3, 0., waveTop) * 0.05;
					col += (1. - abs(0.5 - smoothstep(waveTop, waveBottom, 0.))) * 0.06;
					col += smoothstep(-0.3, 0., waveBottom) * -0.05;

					fragColor.xyz = lerp(fragColor.xyz, col, smoothstep(0., aa, waveTop));
				
				}
				fragColor.w = 1.0;
				return fragColor;
			}
			ENDCG
			}
	}
}

