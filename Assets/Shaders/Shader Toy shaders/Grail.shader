// https://www.shadertoy.com/view/Wl3GWX
Shader "Custom/Grail"
{

	Properties
    {
	    _MainTex ("MainTex", 2D) = "white" {}
	}

	SubShader
	{
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct VertexInput 
            {
                fixed4 vertex : POSITION;
                fixed2 uv:TEXCOORD0;
            };

            struct VertexOutput 
            {
                fixed4 pos : SV_POSITION;
                fixed2 uv:TEXCOORD0;
            };

            //Variables
            sampler2D _MainTex;

            #define PI 3.141592654

            fixed3 norm_frac(fixed3 x)
            {
                fixed3 p=frac(x);
                return 8.0*p*(1.0-p)-1.0;
            }

            fixed noise(fixed a)
            {
                fixed k = frac(sin(131.33 * a + 23.123) * 131.133);
                return k;
            }

            fixed3 noise(fixed3 a)
            {
                fixed3 k = frac(sin(131.33 * a + 23.123) * 131.133);
                return k;
            }

            fixed map(fixed l)
            {
                fixed lm = 1.0;
                l = clamp(1e-5, l, l);
                fixed lm2 = lm * lm;
                fixed lm4 = lm2 * lm2;
                return sqrt(lm4 / (l * l) + lm2);
                // return 1.0/(l+1e-5);
            }

            fixed4 BlurSampler(sampler2D tex,fixed2 uv,fixed2 w)
            {
                fixed4 color=tex2D(tex,uv);
                color+=tex2D(tex,uv+fixed2(0.0,w.y));
                color+=tex2D(tex,uv-fixed2(0.0,w.y));
                color+=tex2D(tex,uv+fixed2(w.x,0.0));
                color+=tex2D(tex,uv-fixed2(w.x,0.0));
                return 0.2*color;
            }

            fixed3 fbm_noise(fixed2 coord,fixed ft)
            {
                fixed len=length(coord);
                fixed dis=map(len);
                fixed3 kp = fixed3(coord * max(dis, 1.0), dis);

                fixed fre=1.0;
                fixed ap=0.5;
                fixed3 d= fixed3(1.0,1.0,1.0);
                [unroll(100)]
                for(int i=0;i<5;i++)
                {
                    kp=lerp(kp,kp.yzx,0.1);
                    kp+=sin(0.75*kp.zxy * fre+ft*_Time.y);
                    d -= abs(dot(sin(kp), norm_frac(kp.yzx)) * ap);
                    fre*=-2.0;
                    ap*=0.5;
                }
                return fixed3((d));
            }

            fixed3 DrawLines(fixed2 coord,fixed fre,fixed ap,fixed bias)
            {
                
                fixed len=length(coord);
                fixed depth=map(len);
                fixed frag=(sin((depth-2.0*bias)*4.0)+1.0)*0.5;
                fixed3 color=lerp(fixed3(0.0,0.0,0.99),fixed3(0.0,1.0,1.0),frag*0.5);
                // fixed3 color=fixed3(0.0,0.5,0.99);
                fixed angle =atan2(coord.x,coord.y);

                fixed p=angle+fre*depth+bias;
                fixed base=1.001;
                fixed k=0.1/(0.1+len);
                color*=smoothstep(base-k*k*k,base,(sin(p*3.0)+1.0)*0.5);
                return 6.0*color*smoothstep(10.0,1.0,depth)*frag*ap;
            }

            float3 DrawCenter(float2 coord)
            {
                float thre=8.0;
                float3 color=float3(0.0,0.3,0.8);
                float l=length(coord);
                
                float d=map(l);
                float f0=smoothstep(0.09,0.13,l);
                float f1=2.0*smoothstep(thre-0.54,thre,d);
                f1+=smoothstep(0.0,thre,d);
                return color*f0*f1;
            }


            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(VertexOutput i) : SV_Target
            {
            
                fixed2 uv=i.uv/1;
                fixed2 w=1.0/1;
                fixed2 coord=uv*2.0-1.0;
                coord.y*=1/1;

                fixed3 color= fixed3(0.0,0.0,0.0);
                fixed ap= abs(fbm_noise(coord,0.5).x);

                // color=max(color,DrawCenter(coord));
                color = max(color,DrawCenter(coord));
               // color=max(color,BlurSampler(_MainTex,uv,w).xyz)*(1.0+0.2*ap);
                color=max(color,DrawLines(coord,1.0,ap,0.0+0.2*_Time.y));
                color=max(color,0.5*DrawLines(coord,3.0,ap,PI*0.2+0.3*_Time.y));
                color=max(color,0.3*DrawLines(coord,6.0,ap,PI*0.2+0.5*_Time.y));

                return fixed4(color,1.0);

            }
            ENDCG
        }
    }
}

