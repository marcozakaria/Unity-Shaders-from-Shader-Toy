// https://www.shadertoy.com/view/ttVSWd
Shader "Unlit/SamplingArtFacts"
{
    Properties
    {
         _Scale("Scale",Range(0.01,10.0)) = 1.0
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed2 Triwave(fixed2 x)
            {
                return 1.0-4.0*abs(0.5-frac(0.5*x + 0.25));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 pt = i.uv;
    
                //fixed FACTOR = 1.0;
                fixed2 uv = frac(Triwave(_Scale*pt));
                uv = frac(Triwave(_Scale*uv));
            // uv = frac(Triwave(_Scale*uv));
                //uv = frac(Triwave(_Scale*uv));
                fixed2 p = fixed2(uv.x+uv.y, uv.x+uv.y)*fixed2(0.5,0.5);
                
                fixed d = distance(uv,p);
                
                fixed3 col = fixed3(0,0,0);
                col+= smoothstep(0.11,0.05,d);
                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
