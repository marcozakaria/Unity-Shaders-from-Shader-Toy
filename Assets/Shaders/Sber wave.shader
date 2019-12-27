// https://www.shadertoy.com/view/Wt3GDS
Shader "Custom/Sber wave "
{
	Properties
	{
		_Color("Color Back",Color)=(1.0,1.0,1.0,0.5)
		_LineColor("Line Color",Color)=(0.1, 0.6, 0.2,1.0)
		_Length("Line Length",Range(0.0,1.0)) = 0.3
		_Speed("Speed",Range(0.0,10.0)) = 2.0
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
				fixed2 uv : TEXCOORD0;
				fixed4 tangent : TANGENT;
				fixed3 normal : NORMAL;
			};


			struct VertexOutput 
			{
				fixed4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0;
			};

			//Variables
			fixed4 _Color;
			fixed4 _LineColor;
			fixed _Length;
			fixed _Speed;

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag(VertexOutput i) : SV_Target
			{
				// Normalized pixel coordinates (from 0 to 1)
				fixed2 uv = i.uv / 1;

				fixed time = _Time.y * _Speed;
				// Time varying pixel color
				fixed4 col = _Color;

				fixed4 lineColor = _LineColor;

				fixed w = uv.y - _Length;
				w += sin(uv.x * 4. + time / 3.) / 8.;
				w += sin(uv.x * 8. + time / 2.) / 16.;
				w += sin(uv.x * 16. - time / 1.) / 32.;

				w = smoothstep(0.02, 0., w);
				w -= step(0.9, sin(uv.x * 220.));

				w -= smoothstep(0.3, 0., uv.x);
				w -= smoothstep(0.7, 1., uv.x);
				col = lerp(col, lineColor, w);

				// Output to screen
				return fixed4(col);
		}
	ENDCG
	}
  }
}
