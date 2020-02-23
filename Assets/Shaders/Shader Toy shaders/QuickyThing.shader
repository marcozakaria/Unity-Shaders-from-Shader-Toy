// https://www.shadertoy.com/view/3tKXzw
Shader "Unlit/QuickyThing"
{
    Properties
    {
        _Scale("Scale",Range(1.0,5.0)) = 2.0
        _Transision("Transition rate",Range(0.0,1.0)) = 0.5
        _Speed("Speed",Range(0.1,10.0)) = 3.0
        _LinesCount("Lines Count",Range(1.0,20)) = 4
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        LOD 100
        Blend One OneMinusSrcAlpha

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

            fixed _Scale, _Speed, _Transision,_LinesCount;        

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed2x2 Rotate(fixed a) 
            {
                float c=cos(a), s=sin(a);
                return fixed2x2(c,-s,s,c);
            }

            fixed Xor(fixed a,fixed b) 
            {
                return a*(1.-b) +b*(1.-a);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed realTime = _Time.y * _Speed + 5500.; // Yeah, effect works far in time
                fixed2 uv = (i.uv - 0.5) * _Scale;
                fixed2 uuv = uv;
                uv *=length(cos(uv*2.8));
                fixed z = (cos(realTime*.1)*.5 + 1.);
                mul(uv, Rotate(cos(realTime)*.1) * z);
                                
                fixed aid = atan2(uv.y,uv.x) * _LinesCount;
                uv = 12. * abs(mul(uv, Rotate(aid+frac(length(uv*4.) + aid*.25) )));
                uv.x = sin(floor(uv.x) + -realTime*.5*cos(realTime*.25)*.005)*.5 + .5;
                uv.x = Xor(uv.x, cos(floor(uv.y) + realTime*.5*sin(realTime*.25)*.005)*.5 + .5);
                fixed3 col = fixed3(uv.x,uv.x,uv.x);
            
                fixed flash = smoothstep(.5,1.,col).r;
                col =col * 0.10/(length(uuv) - (.03*z+floor(cos(aid*4.+flash))*.005)) ;
                col = lerp(fixed3(.1,.0,.1), fixed3(.1 , .1 +flash*.5,1.-(1.-flash)*.5 ), col);
                
                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
