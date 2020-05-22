// https://www.shadertoy.com/view/WtdXR8
Shader "Unlit/GlowingMarbilingBlack"
{
    Properties
    {
        _Speed("Speed",Range(0.01,10.0)) = 1.0
        _Scale("Scale",Range(1.0,10.0)) = 2.0
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
                fixed2 uv =  (_Scale * i.uv - _ScreenParams.xy) ;

                fixed time = _Time.y * _Speed;
                for(float i = 1.0; i < 5.0; i++)
                {
                    uv.x += 0.6 / i * cos(i * 2.5* uv.y + time);
                    uv.y += 0.6 / i * cos(i * 1.5 * uv.x + time);
                }
                
                return fixed4(fixed3(0.1,0.1,0.1)/abs(sin(time - uv.y - uv.x)), 1.0);
            }
            ENDCG
        }
    }
}
