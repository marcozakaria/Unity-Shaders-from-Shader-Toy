//https://www.shadertoy.com/view/wt3SR4
Shader "Unlit/Fractal Lines"
{
    Properties
    {
       _Speed("Speed",Range(0.01,10.0)) = 0.5
       _Scale("Scale",Range(1.0,50.0)) = 20.0
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

            float2x2 Rot(float a) 
            {
                float s = sin(a);
                float c = cos(a);
                return float2x2(c, -s, s, c);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = abs(i.uv-.5) * _Scale; // abs to make simitry with both sides
                fixed time = _Time.y * _Speed;

                uv *= sin(length(cos(uv) + time));
                uv *= frac(length(uv*.1 - time*.1) + time*.12);
                
                fixed2 id= floor(uv);
                uv = frac(uv + time*.13) - .5;
                fixed d = 0.;
                
                if(fmod(id.x,2.) - fmod(id.y,2.) == 0.) 
                {
                    d = min(abs(uv.x),.1);
                } 
                else 
                {   
                    d = min(abs(uv.y),.1);
                }

                d = smoothstep(0.1,.00,d);
                fixed3 col;

                if( fmod(id.x,2.) - fmod(id.y,2.) == 0.) 
                {
                    col = lerp(fixed3(.1,0.1,0.1),fixed3(.9,.3,.2*(1.-d)),fixed3(d,d,d));
                }
                else
                {
                    col = lerp(fixed3(.1,0.1,0.1),fixed3(.2,.3*(1.-d),.9),fixed3(d,d,d));
                }
                
                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
