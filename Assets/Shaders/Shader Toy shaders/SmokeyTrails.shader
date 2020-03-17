// https://www.shadertoy.com/view/3lVSWt
Shader "Unlit/SmokeyTrails"
{
    Properties
    {
        
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

            #define bpm 150.
            #define beat floor(_Time.y*bpm/60.)
            #define ttime _Time.y*bpm/60.

            fixed2x2 r(fixed a)
            {
                fixed c=cos(a),s=sin(a);
                return fixed2x2(c,-s,s,c);
            }

            fixed fig(fixed2 uv)
            {
                uv = mul(uv, r(-3.1415*.9));
                return min(1.,.1/abs( (atan2(uv.y,uv.x)/2.*3.1415)-sin(- ttime+(min(.6,length(uv)))*3.1415*8.)));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv =i.uv - 0.5; 
                uv += fixed2(cos(_Time.y*.1),sin(_Time.y*.1));
                uv = mul(uv,r(_Time.y*.1));
                
                fixed3 col = fixed3(0.0,0.0,0.0);
                
                for(float y=-1.;y<=1.;y++)
                {
                    for(float x=-1.;x<=1.;x++)
                    {
                        fixed2 offset = fixed2(x,y);
                        fixed2 id = floor(mul((uv+offset), r(length(uv+offset))));
                        fixed2 gv = frac(mul((uv+offset), r(length(uv+offset)))) -0.5;
                        gv = mul(gv, r(cos(length(id)*10.)));
                        
                        float d = fig(gv);+fig(gv+fixed2(sin(ttime+length(id))*.1, cos(_Time.y)*.1));
                        col += fixed3(d,d,d)/exp(length(gv)*6.);
                    }
                }
                
                col = lerp(fixed3(.1,.01,.02),fixed3(.8,.4,.2),col);
                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
