// https://www.shadertoy.com/view/WtVGzz

Shader "Custom/Accidental Fractal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _DistMul("Dist Multiplayer",Range(0.0,10.0)) = 1.0
        _Speed("Speed",Range(0.0,4.0)) = 1.0
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _DistMul;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);               
                return o;
            }

            float f(float x, float y)
            {
                float r = sqrt(x * x + y * y);
                float a = atan2(x,y);//atan(y, x);
                return sin(a+1.0*r*r) + r * (1.0 - cos(_Time.y * _Speed)) * 0.001;               
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed dist = abs(f(i.vertex.x, i.vertex.y)) * _DistMul;              

                col *= fixed4(dist,dist,dist,1.0); 
                return col;
            }
            ENDCG
        }
    }
}
