// https://www.shadertoy.com/view/ttK3W3
Shader "Unlit/PolyGrid"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}

        _Amount("amount",Range(0.0,1.0))= 0.5
        _LineMove(" line move ",Range(0.0,2.0)) = 0.1

        _ColorX("Color X",Color) = (0.7,0.4,1.0)
        _ColorY("Color Y",Color) = (0.7,0.2,0.6)
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
           // float4 _MainTex_ST;

            fixed _Amount;
            fixed _LineMove;

            fixed3 _ColorX;
            fixed3 _ColorY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; //TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                fixed2 uv = i.uv;

                float modOffset = sin(_Time.y * _LineMove);
                
                // Create lines with step()
                fixed xval = step(abs(sin(_Amount)), fmod(modOffset + 20.0, uv.x));
                fixed3 xlines = fixed3(xval, xval, xval);
                fixed yval = step(abs(sin(_Amount)), fmod(modOffset + 20.0, uv.y));
                fixed3 yLines = fixed3(yval, yval, yval);
                
                // Add color to lines
                xlines = xlines * (uv.x*_ColorX);// fixed3(uv.x * 0.7, uv.x * 0.4, uv.x * 1.0);
                yLines = yLines * (uv.y * _ColorY);//fixed3(uv.x * 0.7, uv.x * 0.2, uv.x * 0.6);
                
                fixed3 col = lerp(yLines, xlines, uv.y);

                return fixed4(col,(xval+yval)/2.0);
            }
            ENDCG
        }
    }
}
