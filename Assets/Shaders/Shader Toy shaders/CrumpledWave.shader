// https://www.shadertoy.com/view/3ttSzr
Shader "Unlit/CrumpledWave.shader"
{
    Properties
    {
        _Speed("Speed",Range(0.01,10.0)) = 0.5
        _Scale("Scale",Range(1.0,10.0)) = 2.0
        _Color("Color",Color) = (0.1,0.3,0.95)
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
            fixed3 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv =  (_Scale * i.uv );

                fixed time = _Time.y * _Speed;
                for(float i = 1.0; i < 8.0; i++)
                {
                    uv.y += i * 0.1 / i * sin(uv.x * i * i + time) * sin(uv.y * i * i + time);
                }
                
                fixed3 col;
                col.r  = uv.y - _Color.x;
                col.g = uv.y + _Color.y;
                col.b = uv.y + _Color.z;
                
                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
