//https://www.shadertoy.com/view/WldSzN
Shader "Unlit/DownStairs"
{
    Properties
    {
        _Speed("Speed",Range(0.01,10.0)) = 0.5
        _Scale("Scale",Range(1.0,10.0)) = 1.0
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

            fixed _Speed;
            fixed _Scale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = i.uv * _Scale;

                fixed2 cellStart = floor(uv * _Scale);
                fixed2 center = (cellStart + 0.5) / _Scale;
                fixed cellDistance = distance(uv, center);
                fixed t = _Time.y*_Speed + cellStart.x + cellStart.y;

                fixed r = (0.2 + sin(t) * 0.5) / _Scale*2.;
                fixed c = smoothstep(0.0, 0.005, cellDistance - r);
                
                return fixed4(c,c,c, 1.); 
            }
            ENDCG
        }
    }
}
