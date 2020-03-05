// https://www.shadertoy.com/view/wlGSzc
Shader "Unlit/FloatingPoints"
{
    Properties
    {
        _Speed("Speed",Range(0.0,10.0)) = 1.0
        _Scale("Scale",Range(0.0,25.0)) = 1.0
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

            fixed _Speed, _Scale;

            fixed DistanceToLine(fixed3 LineStart, fixed3 LineEnd, fixed3 Point)
            {
                fixed3 lineStartToEnd = LineEnd - LineStart;
                return length(cross(Point - LineStart, lineStartToEnd))/length(lineStartToEnd);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv-0.5) *_Scale;//(fragCoord - iResolution.xy * 0.5)/iResolution.y;
                fixed time = _Time.y * _Speed;
                
                fixed sineOfTime = sin(time);
                fixed cosineOfTime = cos(time);
                
                fixed3 rayOrigin = fixed3(0, 0, -1.0 + sineOfTime * 0.25);
                fixed3 uvPoint = fixed3(uv, 0);
                
                fixed filledIn = 0.0;

                for (fixed x = -1.0; x <= 1.0; x += 0.5)
                {
                    for (fixed y = -1.0; y <= 1.0; y += 0.5)
                    {
                        for (fixed z = -1.0; z <= 1.0; z += 0.5)
                        {
                            fixed3 pointt = fixed3(x, y, z + 5.0);
                            pointt.x += sineOfTime * 0.75;
                            pointt.z -= cosineOfTime * 0.75;
                            pointt.y -= (cosineOfTime + sineOfTime) * 0.75;
                            pointt.x += (frac(x * 47350.6 - y * 7076.5 + z * 3205.25 + sin(time * x * y * z) * 0.5) - 0.5) * 1.75;
                            pointt.y += (frac(-x * 155.2 + y * 2710.66 + z * 71820.43 - cos(time * x * y * z) * 0.5) - 0.5) * 1.75;
                            pointt.z += (frac(x * 21255.52 + y * 510.16 - z * 6620.73 - cos(time * x * y * z) * 0.5) - 0.5) * 1.75;
                            fixed distanceToLine = DistanceToLine(rayOrigin, uvPoint, pointt);
                            if (distanceToLine < frac(x * 6250.55 + y * 325.35 + z * 6207.58) * 0.1 + 0.05)
                            {
                                filledIn += 0.25 * frac(x * 1250.25 + y * 25.5 + z * 120.01);
                            }
                            filledIn += max(0.01, sineOfTime * 0.5 + 1.0 - distanceToLine) * 0.01;
                        }
                    }
                }
                
                fixed3 color = filledIn * fixed3(uv.x + 0.5, uv.y + 0.5, uv.x * uv.y + 0.5) * (max(0.5, (cos(time * 0.35 + 0.25) + 0.5)) * 10.0);
                
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
