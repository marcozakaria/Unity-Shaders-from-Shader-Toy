//https://www.shadertoy.com/view/3lGSR3
Shader "Unlit/RotatingWavesCircle"
{
    Properties
    {
        _Speed("Speed",Range(0.0,5.0)) = 1.0
        _Scale("Scale",Range(1.0,2.0)) = 1.0
        _NumLines("Number of lines",Range(1.0,5.0)) = 3.0
        _LineThickness("Line Thickness +",Range(0.001,0.2)) = 0.01
        _LineThickness2("Line Thickness -",Range(0.001,0.2)) = 0.01       

        _IntersectionDensty("Intersection Densty",Range(0,30)) = 6
        _PowerValue("Power Value",Range(0.25,10)) = 3.0
        _DivisionValue("Division Value",Range(0.1,3.0)) = 2.0
        _bgColor("BG Color",Color) = (.5, .6, .3, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed _NumLines, _Speed, _Scale, _LineThickness, _LineThickness2, _IntersectionDensty, _PowerValue, _DivisionValue;
            fixed4 _bgColor;

            fixed3 circle(fixed2 uv, fixed rad, fixed i)
            {
                fixed d  = length(uv);
                fixed a  = atan2(uv.x, uv.y);
                fixed c = 0.; 
                fixed time = _Time.y *_Speed;   
                
                rad += 0.06 * cos(_IntersectionDensty*a - i*(1.5707) + time) * pow((1. + cos(a - time)) / _DivisionValue, _PowerValue); //1.57079633 = half pi
                c += smoothstep(rad, rad+_LineThickness, d);

                rad *= 0.95;
                c -= smoothstep(rad, rad+_LineThickness2, d);
                
                //any ideas how to color the individual waves?
                 //if(i == 0.) return fixed3(1., 0., 0.);
                 //if(i == 1.) return fixed3(0., 1., 0.); //kind of
                return fixed3(c, c, c);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv - 0.5) * _Scale;
                
                fixed3 col = fixed3(1.0,1.0,1.0);
                fixed r = 0.4;
                
                for(fixed i = 0.; i < _NumLines; i+=1.)
                {
                    col += circle(uv, r, i);
                }
                
                //fixed4 bg = fixed4(.5, .6, .3, 1.0);
                return lerp(_bgColor, fixed4(col, 1.0), 0.8);
            }
            ENDCG
        }
    }
}
