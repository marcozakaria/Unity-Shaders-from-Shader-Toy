// https://www.shadertoy.com/view/3tKGRD

Shader "Custom/Circular Calender"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}

        _Speed1("Speed 1",Range(0.0,2.0)) = 0.5
        _Speed2("Speed 2",Range(0.0,2.0)) = 0.5
        _Speed3("Speed 3",Range(0.0,2.0)) = 0.5
        _Speed4("Speed 4",Range(0.0,2.0)) = 0.5
        _Speed5("Speed 5",Range(0.0,2.0)) = 0.5

        _BlurAmount("Blur Amount",Range(0.0,1.0)) = 0.01
        _RadiusSize("Radius ",Range(0.0,1.0)) = 0.85
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

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            fixed _Speed1;
            fixed _Speed2;
            fixed _Speed3;
            fixed _Speed4;
            fixed _Speed5;

            fixed _BlurAmount;
            fixed _RadiusSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;//TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //fixed4 col = tex2D(_MainTex, i.uv);

                fixed2 uv = ( 2.*i.uv - 1 ) /1;
                //fixed2 uv = i.uv;
                fixed2 p = fixed2(atan2(uv.y,uv.x)/6.283185+ 0.5, length(uv));
                
                fixed b = _BlurAmount;// .5/iResolution.y;	//blur
                fixed r = _RadiusSize;	//size
                
                // year
                //float ty = iDate.y/12. + iDate.z/30./12. + iDate.w/86400./30./12.;
                fixed ty = frac(_Time.w * _Speed1/5.);
                fixed dy = p.x-ty;
                fixed sy = smoothstep(1./p.y*b, -1./p.y*b, dy);
                fixed cy = smoothstep(1./p.y*b*3., -1./p.y*b*3., p.y-r);
                fixed3 year = fixed3(max(sy*cy, .15*cy) * fixed3(.2,.35,.5));
                
                // month
                //float tm = iDate.z/30. + iDate.w/86400./30.;
                fixed tm = frac(_Time.w * _Speed2/2.);
                fixed dm = p.x-tm;
                fixed sm = smoothstep(1./p.y*b, -1./p.y*b, dm);
                fixed cm = smoothstep(1./p.y*b*2.6, -1./p.y*b*2.6, p.y-r+.167);
                fixed3 month = fixed3(max(sm*cm, .15*cm) * fixed3(.43,.36,.49));

                // day
                // float td = iDate.w/86400.;
                fixed td = frac(_Time.w * _Speed3/8.);
                fixed dd = p.x-td;
                fixed sd = smoothstep(1./p.y*b, -1./p.y*b, dd);
                fixed cd = smoothstep(1./p.y*b*2.2, -1./p.y*b*2.2, p.y-r+.333);
                fixed3 day = fixed3(max(sd*cd, .15*cd) * fixed3(.76,.42,.53));
                
                // hour
                //float th = fract(iDate.w/3600.);
                fixed th = frac(_Time.w * _Speed4/3.);
                fixed dh = p.x-th;
                fixed sh = smoothstep(1./p.y*b, -1./p.y*b, dh);
                fixed ch = smoothstep(1./p.y*b*1.8, -1./p.y*b*1.8, p.y-r+.5);
                fixed3 hour = fixed3(max(sh*ch, .15*ch) * fixed3(.95,.43,.46));
                
                // minute
                // float tmi = fract(iDate.w/60.);
                fixed tmi = frac(_Time.w * _Speed5/6.);
                fixed dmi = p.x-tmi;
                fixed smi = smoothstep(1./p.y*b, -1./p.y*b, dmi);
                fixed cmi = smoothstep(1./p.y*b*1.2, -1./p.y*b*1.2, p.y-r+.667);
                fixed3 minute = fixed3(max(smi*cmi, .15*cmi) * fixed3(.98,.7,.58));
                
                fixed3 col = lerp(lerp(lerp(lerp(year, month, cm), day, cd), hour, ch), minute, cmi);

                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
