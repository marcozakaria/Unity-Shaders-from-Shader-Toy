// https://www.shadertoy.com/view/WlySzD
Shader "Unlit/hypnotize and stuff"
{
    Properties
    {
        _Scale("Scale",Range(1.0,5.0)) = 2.0
        _Transision("Transition rate",Range(0.0,1.0)) = 0.5
        _Speed("Speed",Range(0.1,10.0)) = 2.0
        _LinesCount("Lines Count",Range(1.0,25)) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
     

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

            fixed _Scale, _Speed, _Transision, _LinesCount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed t = _Time.y * _Speed;
                fixed2 uv = i.uv * _Scale;
                //fixed u = uv.x;
                //fixed v = uv.y;
                
                fixed l = length(uv - _Scale/2.0);// - fixed2(1.,1.)); // radius
                fixed d = distance(sin(t+uv), fixed2(sin(l*10.+sin(uv.x)+t), cos(l*5.)));
                
                fixed circles = sin(dot(sin(t) + _LinesCount, l * _LinesCount));
                
                fixed shape = circles - d;
                
                fixed3 color = fixed3(uv.x, uv.y, uv.x *uv.y + sin(t)*.5 + .5);
                
                fixed3 col = fixed3(shape + color);
                //col = lerp(col,0,length(l)*_Transision*_Scale);
                
                return fixed4(col,1.0);//clamp(shape,0.01,1.0));
            }
            ENDCG
        }
    }
}
