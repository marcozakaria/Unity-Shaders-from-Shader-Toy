// https://www.shadertoy.com/view/tlyXzw
Shader "Unlit/TrippyVisuals"
{
    Properties
    {
        _Speed("Speed",Range(0.0,10.0)) = 1.0
        _Scale("Scale",Range(0.0,25.0)) = 5.0
        _Color("Color Multiply",Color) = (0.7, 1.0, 1.2, 1.0)
        _LineCount("Line count",Range(0.0,100)) = 10
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

            fixed _Speed, _Scale, _LineCount;
            fixed4 _Color;
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = ( i.uv - 0.5) * _Scale;
                fixed time = _Time.y * _Speed;

                fixed betrag = length(fixed2(uv.x,uv.y));
                fixed winkel = atan2(uv.y, uv.x);
                fixed r = abs(sin((time*0.25 + winkel) * _LineCount + cos((betrag + time)*5.)*2.));
                fixed g = sin(winkel * _LineCount + cos((betrag - time)*5.)*2.);
                fixed b = abs(sin((r*3.14) / (1.5+sin(time))));
                
                return fixed4(_Color.r*r, g*_Color.g, _Color.b*b, 1.0);
            }
            ENDCG
        }
    }
}
