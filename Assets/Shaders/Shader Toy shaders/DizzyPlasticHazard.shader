// https://www.shadertoy.com/view/wltXWM
Shader "Custom/DizzyPlasticHazard"
{

	Properties
	{
		_Scale("Scale",Range(1.0,50.)) = 20
		_Speed("Speed",Range(0.01,5.0)) = 1.0
		_LinesST("Lines ST",Range(1.0,50.0)) = 10.5
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

		fixed _Scale;	
		fixed _Speed;	
		fixed _LinesST;

		VertexOutput vert (VertexInput v)
		{
			VertexOutput o;
			o.pos = UnityObjectToClipPos (v.vertex);
			o.uv = v.uv;
			return o;
		}

		fixed4 frag(VertexOutput i) : SV_Target
		{			
			fixed2 uv = i.uv*_Scale;

			fixed b = 2./3. * uv.y;
			fixed r = (sqrt(3.)/3. * uv.x - uv.y/3. );
			fixed g = -(sqrt(3.)/3. * uv.x + uv.y/3. );  
							
			fixed time = _Time.y * _Speed;
		
			fixed pi = 3.14159;
			fixed tri = sign(fmod(floor(r / pi) + floor(g / pi) + floor(b / pi), 2.) * 2.0 - 1.0) ;
			
			fixed value = cos(r + sin(time/ 2.) * 3.14159) * cos(g + sin(time) * 3.14159) * cos(b + sin(time/ 3.) * 3.14159) * tri * (_LinesST);
			value = sin(value) * 3.0;			

			fixed low = abs(value);
			fixed med = abs(value) - 1.50;
			fixed high = abs(value) - 2.5;

			if(value > 0.0) 
			{
				return fixed4(med, high, med, 1.0);  
			}
			else 
			{
				return fixed4(min(0.5, med / 2.0), high, med, 1.0);
			}
		}
		ENDCG
		}
	}
}

