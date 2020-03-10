Shader "Unlit/GrainEffect"
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

            fixed _Scale, _Speed;

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

                fixed3 col = fixed3(0.2,0.1,0.5); // back ground color
                
                fixed dt = dot(uv, fixed2(15.9898, 78.233)); // any random numbers
                fixed noise = frac(sin(dt) * 4378.5453 + _Time.y);
                fixed3 grain = fixed3(noise, noise, noise) * (1.2 - col);
                col += grain*0.15; // add grain to color
                
                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
