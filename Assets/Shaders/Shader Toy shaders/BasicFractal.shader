// https://www.shadertoy.com/view/tltSWs
Shader "Unlit/BasicFractal"
{
    Properties
    {
        _MaxIterations("Max Iterations",Range(1,15)) = 6
        _InnerScale("Inner Scale",Range(0.1,10)) = 2
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

            fixed _MaxIterations;
            fixed _InnerScale;

            fixed2 rot(fixed2 uv,float a)
            {
                float c=cos(a);
                float s=sin(a);
                return mul(uv,fixed2x2(c,-s,s,c));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv-0.5);

                //global zoom
                uv*= sin(_Time.y)*0.5+1.5;

                //shift, mirror, rotate and scale 6 times...
                for(int i=0;i<_MaxIterations;i++)
                {
                    //uv *= _InnerScale;    //<-Scale
                   // uv = rot(uv,_Time.y); //<-Rotate
                   // uv = abs(uv);         //<-Mirror
                    //uv -= 0.5;            //<-Shift
                    uv = abs(rot(uv*_InnerScale,_Time.y)) -0.5; 
                }

                //draw a circle
                fixed c = length(uv) > 0.4? 0.0:1.0;	

                return fixed4(c,c,c,1.0);
            }
            ENDCG
        }
    }
}
