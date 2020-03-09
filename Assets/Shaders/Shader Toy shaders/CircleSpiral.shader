// https://www.shadertoy.com/view/WlKXDG
Shader "Unlit/CircleSpiral"
{
    Properties
    {
        
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

            fixed circle(fixed x, fixed y, fixed thres)
            {
                fixed r_sq = x * x + y * y;
                return 0.5 - clamp((r_sq - thres) * 8.0, -0.5, 0.5);
            }

            void rot(inout fixed2 p, fixed a) 
            {
                fixed c = cos(a);
                fixed s = sin(a);
                p = fixed2(c*p.x + s*p.y, -s*p.x + c*p.y);
            }

            fixed zigzag(fixed x)
            {
                return abs(1. - fmod(x, 2.0));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                 fixed PI = 3.1415;
                 fixed rotSpeed = -5.;
                 fixed zoomSpeed = -3.;
                 fixed spiralSpeed = 3.;
                
                // Normalized pixel coordinates (from 0 to 1)
                //fixed scale = min(_ScreenParams.x, _ScreenParams.y);
                fixed2 uv = (i.uv-0.5);// / scale;
                //uv -= fixed2(_ScreenParams.x / scale, _ScreenParams.y / scale) / 2.;
                //uv *= 2.0;
                
                fixed distance = log(uv.x*uv.x+uv.y*uv.y) / 2.;
                fixed angle = atan2(uv.x, uv.y) / PI;
                
                fixed spiral = 0.7 * zigzag(distance * 2.0 + angle * 4.0 + _Time.y * spiralSpeed) + 0.15;
                
                fixed distZag = zigzag(16.0 * distance + _Time.y * zoomSpeed);
                fixed angleZag = zigzag(48.0 * angle + _Time.y * rotSpeed);
                
                fixed circleOut = circle(distZag, angleZag, spiral);
                
                // Output to screen
                return fixed4(circleOut, circleOut, circleOut, 1);
            }
            ENDCG
        }
    }
}
