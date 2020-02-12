// https://www.shadertoy.com/view/wtdSzX
Shader "Unlit/HexagonalGrid"
{
    Properties
    {
       _HexXValue("Hex X Value",Range(0.5,1.5)) = 0.9
       _Speed("Speed",Range(0.01,5.0)) = 1.0
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

            fixed _HexXValue;
            fixed _Speed;

            static const fixed2 s = fixed2(1, 1.7320508);

            fixed hash21(fixed2 p)
            {
                return frac(sin(dot(p, fixed2(141.13, 289.97)))*43758.5453);
            }

            fixed4 getHex(fixed2 p)
            {    
                fixed4 hC = floor(fixed4(p, p - fixed2(.5, 1))/s.xyxy) + .5;
                
                // Centering the coordinates with the hexagon centers above.
                fixed4 h = fixed4(p - hC.xy*s, p - (hC.zw + .5)*s);

                return dot(h.xy, h.xy) < dot(h.zw, h.zw) 
                    ? fixed4(h.xy, hC.xy) 
                    : fixed4(h.zw, hC.zw + .5);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 u = (i.uv); //(fragCoord - iResolution.xy*.5)/iResolution.y;
                
                fixed4 h = getHex(u*5. + s.yx*_Time.y * _Speed);
                
                fixed2 p = abs(h.xy);
                float eDist = max(dot(p, s * _HexXValue), p.x); // Edge distance.

                // Initiate the background to a white color, putting in some dark borders.
                fixed3 col = lerp(fixed3(1.,1.0,1.0), fixed3(0,0,0), smoothstep(0., .03, eDist - .5 + .04));    
                return fixed4(col, 1);  
            }
            ENDCG
        }
    }
}
