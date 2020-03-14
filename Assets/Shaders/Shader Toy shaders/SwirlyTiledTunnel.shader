// https://www.shadertoy.com/view/WslcRr
Shader "Unlit/SwirlyTiledTunnel"
{
    Properties
    {
        _Speed("Speed",Range(0.0,5.0)) = 0.5
        _Scale("Scale",Range(1.0,5.0)) = 2.0

        _Linethicness("Line Thicness",Range(0.01,1.0)) = 0.15
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

            fixed _Speed,_Scale, _Linethicness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            static fixed n = 13.;
            static fixed k = 1.;


            fixed pattern(fixed2 p) // random
            {
                return 0.6 * pow(abs(sin(p.x * 3.141) * sin(p.y * 3.141)), _Linethicness);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv-0.5) * _Scale;
                fixed tt = _Time.y * _Speed;

                fixed2 m;
                fixed cr = k * pow((sin(tt * 0.5) * 3.5 + 0.5), 1.0);
                m.x = atan2(uv.x, uv.y) / 6.283 * n;
                m.x += 1.5 * sin(length(uv) * cr + 3.141);
                m.x += tt;
                m.y = 3. * 1e2 / pow(length(uv), 1e-2);
                m.y += tt + m.x / n;
                m.y += sin(length(uv) * cr * 1.5);

                fixed col = pattern(m);
                return fixed4(fixed3(col,col,col),1.0);
            }
            ENDCG
        }
    }
}
