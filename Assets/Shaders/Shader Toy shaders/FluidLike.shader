// https://www.shadertoy.com/view/wty3DG
Shader "Unlit/FluidLike"
{
    Properties
    {
        _Speed("Speed",Range(0.01,5.0))= 0.1
        _ScaleX("Scale X",Float) = 1.0
        _ScaleY("Scale Y",Float) = 1.0
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

           fixed  _Speed;
           fixed _ScaleX;
           fixed _ScaleY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 p = i.uv * fixed2(_ScaleX, _ScaleY); 
                for(int i=1; i<10; i++)
                {
                    p.x+=(sin( 0.25)) * 0.75/float(i)*sin(float(i)*2.*p.y + _Time.y*_Speed)+ (_Time.y * 69.)/1000.;
                    p.y+=(sin( 0.25)) * 0.75/float(i)*cos(float(i)*5.*p.x + _Time.y*_Speed)+(_Time.y * .69)/1000.;
                }
                float r=cos(p.x+p.y+.025)*.9 + 0.33;
                float g=sin(p.x+p.y+1.)*.55+.5;
                float b=(sin(p.x * 1. +p.y)+cos(p.x+(p.y)))*.5+.28;
                fixed3 color = fixed3(b,g,r);
                color -= 0.002;
               
                return fixed4(color,1.0);
            }
            ENDCG
        }
    }
}
