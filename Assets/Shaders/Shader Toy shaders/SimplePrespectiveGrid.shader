//https://www.shadertoy.com/view/wlGGRy
Shader "Unlit/SimplePrespectiveGrid"
{
    Properties
    {
        _depth("Depth",Range(0.1,2.0)) = 1.0
        _Thickness("Thickness",Range(0.01,0.5)) = 0.04
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

            fixed _depth;
            fixed _Thickness;

            fixed4 frag (v2f i) : SV_Target
            {

                fixed2 uv = (i.uv.xy-.5)/2.;

                fixed d = _depth/abs(uv.y); //depth
                fixed2 pv = fixed2(uv.x*d, d); //perspective
                pv.y += _Time.y; //offset
                pv *= 4.; //scale
                
                fixed2 gpv = abs((frac(pv)-.5)*2.); //grid vector
                
                fixed b = 10./_ScreenParams.y*d; //blur
                fixed t = _Thickness; //thickness
                
                fixed g = 1.-smoothstep(t-b,t+b,gpv.x)*smoothstep(t-b,t+b,gpv.y); //grid
                
                fixed3 col = fixed3(g/d,g/d,g/d);

                return fixed4(col,1.);
            }
            ENDCG
        }
    }
}
