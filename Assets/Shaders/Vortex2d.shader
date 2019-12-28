// https://www.shadertoy.com/view/tltGRs
Shader "Custom/Vortex2d"
{
    Properties
    {
        _Size("Size", Range(0.1,3.0)) = 1.0
        _LineScale("Line Scale",Range(0.2,0.6)) = 0.5
        _LineCount("Line Count",Range(0.1,4.0)) = 0.5
        _Speed("Speed",Range(0.1,10.0)) = 1.0
        _ColorInts("Color Intens",Range(0.1,5.0)) = 0.2

        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
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
            // make fog work
            #pragma multi_compile_fog

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed _Size;
            fixed _LineScale;
            fixed _LineCount;
            fixed _Speed;
            fixed _ColorInts;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            #define t _Time.y
            #define rot(a) float2x2(cos(a), sin(a), -sin(a), cos(a))

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                fixed2 p = i.uv;
                p -= 0.5 ; // position in center
                p /= _Size; // size
                p = mul(p, rot(_LineCount / length(p) + t*_Speed));
                p = log(abs(p));
                fixed c = (_ColorInts / length(_LineScale * p + 1.0) / log(t));

                return fixed4(c,c,c,1.0);
            }
            ENDCG
        }
    }
}
