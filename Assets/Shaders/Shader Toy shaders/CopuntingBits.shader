// https://www.shadertoy.com/view/WlVXWt
Shader "Unlit/CopuntingBits"
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            int nbBits(int v)  
            { 
                v -= v >> 1   & 0x55555555;                    
                v = (v & 0x33333333) + (v >> 2   & 0x33333333);     
                return ( v + (v >> 4) & 0xF0F0F0F ) * 0x1010101   >> 24;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                int2 I = int2(i.uv);
                int value = nbBits(int(i.uv.x) ^ int(i.uv.y)); 
                fixed res = value/ 8.0;
                return fixed4(res,res,res,res);
            }
            ENDCG
        }
    }
}
