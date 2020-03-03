// https://www.shadertoy.com/view/3ttSW2
Shader "Unlit/FloorHexTiling"
{
    Properties
    {
        _Speed("Speed",Range(0.0,10.0)) = 1.0
        _Scale("Scale",Range(0.0,25.0)) = 5.0
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
                UNITY_FOG_COORDS(1)
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
            static fixed2 s = fixed2(1, 1.7320508); // hexagonal triangle tada 1.73 = squareroot 3

            fixed hex(in fixed2 p)
            {
                p = abs(p);
                return max(dot(p, s*.5), p.x);
            }

            fixed4 getHex(fixed2 p)
            {
                fixed4 hC = floor(fixed4(p, p - fixed2(.5, 1))/s.xyxy) + .5;
                fixed4 h = fixed4(p - hC.xy*s, p - (hC.zw + .5)*s);
                return dot(h.xy, h.xy)<dot(h.zw, h.zw) ? fixed4(h.xy, hC.xy) : fixed4(h.zw, hC.zw + fixed2(.5, 1)); 
            }

            fixed aafract(fixed x) 
            {
                fixed v = frac(x),
                    w = fwidth(x);
                return v < 1.-w ? v/(1.-w) : (1.-v)/w;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv =  _Scale*(i.uv-0.5) +(_Time.y*_Speed);
  
                fixed4 h1 = getHex(uv);
                fixed4 h2 = getHex(uv - 1./s);
                fixed4 h3 = getHex(uv + 1.0/s);
                
                fixed v1 = aafract(hex(h1.xy)/.2);
                fixed v2 = aafract(hex(1.5*h2.xy)/0.45);
                fixed v3 = aafract(hex(2.*h3.xy)/0.3);
                
                fixed value =  v1+v2+v3;
                return fixed4(fixed3(value,value,value)/3., 1.0);
            }
            ENDCG
        }
    }
}
