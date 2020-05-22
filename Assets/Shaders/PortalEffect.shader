Shader "Unlit/PortalEffect"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        [HDR]_Color("Color", Color) = (1,1,1,1)
        _MaskTex("Mask Tex", 2D) = "white" {}
        _NoiseTex("Noise Tex", 2D) = "white" {}
        _Speed("Speed",float) = 1.0
        _Strength("Strength",float) = 5.0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100

        Pass
        {
            ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed _Speed, _Strength;
            sampler2D _MaskTex;
            sampler2D _NoiseTex;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            inline void Unity_Twirl_float(fixed2 UV, out fixed2 Out)
            {
                fixed angle = _Strength * length(UV);
                fixed x = cos(angle) * UV.x - sin(angle) * UV.y;
                fixed y = sin(angle) * UV.x + cos(angle) * UV.y;
                fixed Offset = (_Time.y * _Speed);
                Out = fixed2(x + Offset, y + Offset);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MaskTex, i.uv);

                fixed2 uv;
                Unity_Twirl_float(i.uv -0.5, uv);
                
                fixed4 noise = tex2D(_NoiseTex, uv);
                col = col * noise * _Color;

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
