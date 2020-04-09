// https://www.shadertoy.com/view/tt2GRR
Shader "Unlit/GoldCircle"
{
    Properties
    {
        _Color("Main Color",Color) = (1.0, 0.65, 0.2)
        _bgColor("BG Color",Color) = (0.0, 0.0, 0.0)
        _Speed("Speed",Range(0.1,10)) = 2.0
        _Scale("Scale",Range(1.0,5.0)) = 2.0
        _Edges("_Edges count",float) = 8.0
        _InnerRadius("Inner Radius",Range(0.01,0.99)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100

        Pass
        {
            ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

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

            fixed _Scale,_Speed,_Edges,_InnerRadius;
            fixed3 _Color;
            fixed4 _bgColor;

            #define time _Time.y * _Speed

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            void draw(out fixed4 FragColor, in fixed2 vUv)
            {
                float radius = lerp(_InnerRadius, 1.0, 0.01);
                float dist = length(vUv);
                
                float v1, v2;
                fixed2 pol = fixed2(atan2(vUv.x, vUv.y), dist) * _Edges;
                v1 = cos(pol.x - pol.y * 5.0 + time);
                v2 = cos((pol.x + pol.y * 5.0) * 8.0 + time);
                v1 = clamp(v1, 0.0, 1.0);
                v2 = clamp(v2, 0.0, 1.0);
                
                v1 = pow(v1, 10.0);
                v1 *= step(radius, dist) * 0.3;
                v2 *= step(radius, dist) * 0.2;
                
                float d3 = abs(dist - radius);
                float v3 = 2.0 / (1.0 + 20.0 * sqrt(d3));
                
                float alpha = v1 + v2 + v3;
                alpha = clamp(alpha, 0.0, 1.0);
                alpha *= smoothstep(1.0 - radius, 0.0, d3);
                
                //gl_FragColor = fixed4(_Color, alpha);
                FragColor = fixed4(_Color, alpha);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv-0.5)*_Scale;
    
                fixed4 src;
                draw(src, uv);

                return fixed4(lerp(_bgColor, src, src.a) );
            }
            ENDCG
        }
    }
}
