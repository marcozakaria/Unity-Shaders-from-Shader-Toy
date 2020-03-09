// https://www.shadertoy.com/view/wlySWc
Shader "Unlit/Quicky25"
{
    Properties
    {
        _Speed("Speed",Range(0.0,5.0)) = 1.0
        _Scale("Scale",Range(1.0,10.0)) = 1.0
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

            fixed _Scale,_Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed2x2 Rot(fixed a)
            { 	
                fixed c= cos(a),s=sin(a);
                return fixed2x2(c,-s,s,c);
            }

            fixed fig(fixed2 uv) 
            {
                mul(uv, Rot(_Time.y*.33 + cos(length(uv.y-uv.x))));
                return 0.1/smoothstep(0.1, 0.9, abs(uv.x*4.) + sin(_Time.y*.5)*+pow(length(uv),2.));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv - 0.5) * _Scale;
               
                fixed3 col = fixed3(0.,0,0);
                
                fixed colresult = fig(uv) + fig(mul(uv, Rot(3.141/uv.x)));
                col = fixed3(colresult, colresult, colresult);
                fixed2 cc = mul(uv, Rot(-_Time.y));
                col= lerp(fixed3(.0,.0,.0), fixed3(.9 * abs(atan2(cc.y,cc.x))/3.141592,.2,.9), col);
                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
