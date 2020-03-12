//https://www.shadertoy.com/view/3sXyRr
Shader "Unlit/SunShine"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            fixed box(fixed3 p, fixed3 s)
            {
                fixed3 q = frac(p)*2.0 -1.0;
                return length(max(abs(q)-s,0.0));
            }


            fixed trace (fixed3 o,fixed3 r)
            {
                fixed t = 0.0;
                for(int i=0;i<50;i++)
                {
                    fixed3 p = o+r*t;
                    fixed d0 = box(p-fixed3(0,0,0),fixed3(0.25,1,0.5));
                    t+=d0*0.5;
                }
                return t;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = i.uv;//vec2(fragCoord.x/iResolution.x,fragCoord.y/iResolution.y) ;
                uv-= 0.5;
                //uv/= vec2(iResolution.y/iResolution.x,1.0);

                fixed3 r = normalize(fixed3(uv,0.1));
                fixed tt = _Time.y*0.25;
                r.yz *= sin((r.yz*100.0+tt));
                fixed3 o = fixed3(0,0,tt);
                
                fixed t = trace(o,r);

                fixed fog = 0.5/(1.0+t*t*0.1); 
                return fixed4(fixed3(fog+fixed3(1,0.3,0.0)),1);
            }
            ENDCG
        }
    }
}
