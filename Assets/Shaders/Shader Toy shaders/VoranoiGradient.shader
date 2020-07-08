//https://www.shadertoy.com/view/WdlyRS
Shader "Unlit/VoranoiGradient"
{
    Properties
    {
        _ColorA("Color A",Color) = (1,0,0,1)
        _ColorB("Color B",Color) = (0,1,0,1)
        _Scale("Scale",float) = 20
       // _SpeedUV("Speed UV x,y",vector) = (0.2,0.2,0,0)
        _Speed("Speed",Range(0.0,10.0)) = 1.0
        _VoranoiSpeed("Voranoi Division", vector)= (50,30,0,0)

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
                fixed4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
            };

            struct v2f
            {
                fixed2 uv : TEXCOORD0;
                fixed4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            #define t _Time.y*2.

            fixed3 _ColorA, _ColorB;
            fixed _Speed, _Scale;
            fixed2 _VoranoiSpeed;

            fixed2 ran(fixed2 _uv) 
            {
                _uv *= fixed2(dot(_uv,fixed2(127.1,311.7)),dot(_uv,fixed2(227.1,521.7)) );
                return 1.0-frac(tan(cos(_uv)*123.6)*3533.3)*frac(tan(cos(_uv)*123.6)*3533.3);
            }
            fixed2 pt(fixed2 _id) 
            {
                return sin(t*(ran(_id+.5)-0.5)+ran(_id-20.1)*8.0)*0.5;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 voranoi = frac(fixed2(_Time.y/_VoranoiSpeed.x, _Time.y/_VoranoiSpeed.y) * _Speed);
                fixed2 uv = ((i.uv - 0.5) + voranoi) * _Scale;
                
                fixed2 gv = frac(uv)-.5;
                fixed2 id = floor(uv);
                
                fixed mindist = length(gv + pt(id));
                fixed2 vorv = (id+pt(id))/_Scale - voranoi;
                for(fixed i=-1.; i<=1.; i++) 
                {
                    for(fixed j=-1.; j<=1.; j++)
                    { 
                        fixed dist = length(gv+pt(id+fixed2(i,j))-fixed2(i,j));
                        if(dist<mindist){
                            mindist = dist;
                            vorv = (id+pt(id+fixed2(i,j))+fixed2(i,j))/_Scale - voranoi;
                        }
                    }
                }
                
                fixed3 col = lerp(_ColorA, _ColorB, clamp(0.,1.,vorv.x*2.2+vorv.y)*0.5+0.5);
                
                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
