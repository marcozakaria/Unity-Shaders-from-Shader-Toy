// https://www.shadertoy.com/view/wlKSW3
Shader "Unlit/PixelatedLines"
{
    Properties
    {
        _Speed("Speed",Range(0.0,5.0)) = 0.1
        _Scale("Scale",Range(1.0,5.0)) = 2.0
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

            fixed _Scale, _Speed;

            fixed hash21(fixed2 uv) // to get random values
            {
                uv = frac(uv *fixed2(62026.3504,74514.74));
                uv += dot(uv,uv+fixed2(65.408,83.54));
                return frac(uv.x*uv.y);
            }

            fixed sequence(fixed2 uv,fixed2 s) 
            {
                fixed floorX = floor(uv.x*10.);
                uv.y += hash21(fixed2(floorX,floorX)) + tan(floor(uv.x*10.) + _Time.y*hash21(fixed2(floorX+0.1,floorX+0.1))) *_Speed;
                s.y += hash21(floor(uv*100.));
                fixed2 d = abs(uv) - s;
                fixed sqr = length(max(d,0.0)) + min(max(d.x,d.y),0.0);
                return smoothstep(0.00021,0.0002,sqr);
                
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv - 0.5) * _Scale;// (fragCoord.xy -.5* iResolution.xy)/iResolution.y;

                float d = sequence(uv,fixed2(1.,.13));
                fixed3 col = fixed3(0.0,0.0,0.0);
                col.g = d*.9*log2(2.-frac(_Time.y*.33)) / hash21(fixed2(floor(uv.x*100.),floor(uv.x*100.)));
                col.b = d*.9*log2(2.-frac(_Time.y*.66)) / hash21(fixed2(floor(uv.x*75.),floor(uv.x*75.)));
                col.r = d*.9*log2(2.-frac(_Time.y*.1)) / hash21(fixed2(floor(uv.x*50.),floor(uv.x*50.)))/5.0;
                
                col *= smoothstep(1.0,.5*cos(uv.y*10.+_Time.y),length(uv));
                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
