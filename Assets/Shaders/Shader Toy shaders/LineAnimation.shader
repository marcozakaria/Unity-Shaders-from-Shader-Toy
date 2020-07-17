// https://www.shadertoy.com/view/3t2yzG
Shader "Unlit/LineAnimation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _Scale("Scale",float) = 3.0
        _Speed("Speed",float) = 4.0
        _Sp("sp",float) = 2.0
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
                fixed4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
            };

            struct v2f
            {
                fixed2 uv : TEXCOORD0;
                fixed4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            fixed4 _MainTex_ST;

            fixed _Scale, _Sp, _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed2 Line(fixed2 a, fixed2 b, fixed2 p)
            {
                fixed2 pa = p-a, ba = b-a;
                fixed h = min(1., max(0., dot(pa, ba)/dot(ba, ba)));
                
                return fixed2(length(pa - ba * h), h);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv-0.5) * _Scale;
               
                fixed time = _Time.y * _Speed;
                
                fixed a = 0.1 + floor(time) * _Sp;
                fixed2 p1 = fixed2(sin(a), cos(a));
                fixed2 p2 = fixed2(sin(a + _Sp), cos(a + _Sp));
                fixed2 p3 = fixed2(sin(a + _Sp * 2.), cos(a + _Sp * 2.));
                
                fixed2 l1 = Line(p1, p2, uv);
                fixed2 l2 = Line(p2, p3, uv);

                l1.x = smoothstep(0.04, 0.01, l1.x);
                l2.x = smoothstep(0.04, 0.01, l2.x);
                fixed prog1 = pow(frac(time), 0.8);
                fixed prog2 = pow(frac(time), 2.);
                
                fixed al = max(smoothstep(prog2, prog1, l1.y) * l1.x, 
                            smoothstep(prog1, prog2, l2.y) * l2.x);
                
                fixed3 col = fixed3(0,0,0);
                col += al;

                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
