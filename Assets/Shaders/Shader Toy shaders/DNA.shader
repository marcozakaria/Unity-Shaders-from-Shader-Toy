// https://www.shadertoy.com/view/wsXBzr
Shader "Unlit/DNA"
{
    Properties
    {
        _Scale("Scale",Range(1.0,100.0)) = 2.0
        _Speed("Speed",Range(0.1,10.0)) = 1.0

        _ColorLerp("Color lerp",Range(0.0,2.0)) = 0.85
        _Color("Color",Color) = (1,0,0,1)

        _ColorDepth("Color depth",Range(0.0,0.2)) = 0.05
        
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100

        Pass
        {
            ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                fixed4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
            };

            struct v2f
            {
                fixed2 uv : TEXCOORD0;
                fixed4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed _Scale, _Speed, _ColorLerp, _ColorDepth;
            fixed4 _Color;

            #define TIME (_Time.y)
            #define SIN_DENSITY 0.4

            fixed linearstep(fixed a, fixed b, fixed x)
            {
                return clamp((b - x) / (b - a), 0.0, 1.0);
            }

            //x - circle alpha
            //y - circle color
            //Thanks to FabriceNeyret2 for this idea
            fixed2 circle(fixed2 uv, fixed pixelSize, fixed sinDna, fixed cosDna, fixed _sign)
            {
                fixed height = _sign * sinDna;
                fixed depth = abs((_sign * 0.5 + 0.5) - (cosDna * 0.25 + 0.5));	//this 0.25 is quite bad here
                fixed size = 0.2 + depth * 0.1;
                fixed alpha = 1.0 - smoothstep(size - pixelSize, 
                                            size + pixelSize, 
                                            distance(uv, fixed2(0.5, height)));
                
                return fixed2(alpha, depth * _ColorLerp + (1.0 - _ColorLerp));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv-0.5) *_Scale;
                
                //rotation for angle=0.3
                //optimized version of uv *= mat2(cos(angle), sin(angle), -sin(angle), cos(angle)); by FabriceNeyret2
                fixed angle = 0.3;
                uv = mul(uv, fixed2x2(cos(angle + fixed4(0,11,33,0))));

                //move over time
                uv.x -= TIME * 0.5;
                
                //basic variables
                //fixed pixelSize = 0.05;
                fixed2 baseUV = uv;
                uv.x = frac(uv.x);
                fixed lineIndex = floor(baseUV.x);
                fixed dnaTimeIndex = lineIndex * SIN_DENSITY + TIME;
                fixed sinDna = sin(dnaTimeIndex) * 2.0;
                fixed cosDna = cos(dnaTimeIndex) * 2.0;
                
                //draw straight line
                fixed lineSDF = abs(uv.x - 0.5);
                fixed linex = smoothstep(_ColorDepth * 2.0, 0.0, lineSDF);
                
                //cut upper part of the lines
                fixed sinCutLineUp = abs(sinDna);
                fixed sinCutMaskUp = smoothstep(sinCutLineUp + _ColorDepth, sinCutLineUp - _ColorDepth, uv.y);
                
                //cut lower part of the lines
                fixed sinCutLineDown = -abs(sinDna);
                fixed sinCutMaskDown = smoothstep(sinCutLineDown - _ColorDepth, sinCutLineDown + _ColorDepth, uv.y);
                
                //Create first side of dna circles
                fixed2 circle1 = circle(uv, _ColorDepth, sinDna, cosDna, 1.0);
                
                //Second side of dna circles
                fixed2 circle2 = circle(uv, _ColorDepth, sinDna, cosDna, -1.0);
                
                //Calculating line gradient for depth effect
                //Thanks to @tb for this 3D effect idea
                fixed lineGradient = linearstep(sinCutLineUp, sinCutLineDown, uv.y);
                if (sin(lineIndex * SIN_DENSITY + TIME) > 0.0) lineGradient = 1.0 - lineGradient;
                lineGradient = lerp(circle1.y, circle2.y, lineGradient);
                
                //rendering line
                fixed helis = 0.0;
                
                //rendering circles 
                if (circle1.y < circle2.y)
                {
                    helis = lerp(helis, circle1.y, circle1.x);
                    helis = lerp(helis, lineGradient, linex * sinCutMaskUp * sinCutMaskDown);
                    helis = lerp(helis, circle2.y, circle2.x);
                }
                else
                {
                    helis = lerp(helis, circle2.y, circle2.x);
                    helis = lerp(helis, lineGradient, linex * sinCutMaskUp * sinCutMaskDown);
                    helis = lerp(helis, circle1.y, circle1.x);
                }
                
                return _Color * helis;
                //return fixed4(helis,helis,helis,helis*_Color.a);
            }
            ENDCG
        }
    }
}
