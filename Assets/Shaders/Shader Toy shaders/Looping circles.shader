// https://www.shadertoy.com/view/3tdSRn
Shader "Unlit/Looping circles"
{
    Properties
    {
        _Scale("Scale",Range(1.0,10.0)) = 3.0
        _Speed("Speed",Range(0.1,10.0)) = 1.0
        _LerpValue("Lerp value",Float) = 1.0
        _Width("width",Float) = 0.8
        _Power("power",float) = 0.1
        _Radius("radius",Float) = 0.5
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

            fixed _Scale;
            fixed _Speed;
            fixed _LerpValue;
            fixed _Width;
            fixed _Power;
            fixed _Radius;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;             
                return o;
            }

            fixed3 drawCircle(fixed2 pos, fixed radius, fixed width, fixed power, fixed4 color)
            {
                fixed dist1 = length(pos);
                dist1 = frac((dist1 * 5.0) - frac(_Time.y*_Speed));
                fixed dist2 = dist1 - radius;
                fixed intensity = pow(radius / abs(dist2), width); 
                fixed3 col = color.rgb * intensity * power * max((0.8- abs(dist2)), 0.0);
                return col;
            }

            fixed3 hsv2rgb(fixed h, fixed s, fixed v)
            {
                fixed4 t = fixed4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                fixed3 p = abs(frac(fixed3(h,h,h) + t.xyz) * 6.0 - fixed3(t.w,t.w,t.w));
                return v * lerp(fixed3(t.x,t.x,t.x), clamp(p - fixed3(t.x,t.x,t.x), 0.0, 1.0), s);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 pos = (i.uv - 0.5) * _Scale ;
    
                fixed h = lerp(0.5, 0.65, length(pos));
                fixed4 color = fixed4(hsv2rgb(h, 1.0, 1.0), 1.0);
               
                fixed3 finalColor = drawCircle(pos, _Radius, _Width, _Power, color);
                finalColor =  lerp(finalColor,0,length(pos)*_Scale*_LerpValue);
                return fixed4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
