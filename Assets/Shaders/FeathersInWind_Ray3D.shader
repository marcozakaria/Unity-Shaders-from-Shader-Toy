// source : the art of code

Shader "Custom/FeathersInWind_Ray3D"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}

        _Speed("Speed",Range(0.0,5.0)) = 1.0
        _Scale("Scale",Range(1.0,10.0)) = 1.0

        [Header(BG Colors)]
        _BGColorA("Color A",Color) = (0.2, 0.2, 0.7, 1.0)
        _BGColorB("Color B",Color) = (1.0, 0.6, 0.1, 1.0)

        [Header(Feather Properties)]
        _Strandcount("Strand count", float) = 50.0
        _waveLength("wave Length", float) = 0.2
        _XCutRange("XCutRange", float) = 0.9
        
        [Header(3D Settings)]
        _MaxIter("Max Iteration", float) = 10
        _FeatherXRange("Feather X Range", Range(0.0,10.0)) = 8.0
        _FeatherYRange("Feather Y Range", Range(0.0,5.0)) = 3.0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent"  }
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
                float3 ray : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed _Speed, _Scale, _Strandcount, _waveLength, _XCutRange;
            fixed _MaxIter, _FeatherXRange, _FeatherYRange;

            fixed4 _BGColorA, _BGColorB;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);              
                return o;
            }

            float2x2 Rotate(float angle)
            {
                Float s = sin(angle), c = cos(angle);
                return float2x2(c, -s, s, c);
            }

            fixed Feather(fixed2 p)
            {
                fixed d = length(p - fixed2(0, clamp(p.y, -0.3, 0.3))); 
                fixed r = lerp(0.1, 0.0, smoothstep(-0.3, 0.3, p.y));
                fixed m = smoothstep(0.01, 0.0, d-r);

                fixed x = _XCutRange*abs(p.x) / r;
                fixed wave = (1.0 - x) * sqrt(x) + x*(1.0 - sqrt(1.0 - x));
                fixed y = (p.y - wave *_waveLength) * _Strandcount;
                fixed id = floor(y);
                fixed n = frac(sin(id*564.32) * 763.0);  // random number
                fixed shade = lerp(0.5, 1.0 , n);
                fixed strandLength = lerp(0.7, 1.0, frac(n*10.23));

                fixed strand = smoothstep(0.3,0.0, abs(frac(y) - 0.5) - 0.3);
                strand *= smoothstep(0.1, -0.2, x - strandLength);

                d = length(p - fixed2(0, clamp(p.y, -0.45, 0.1))); 
                fixed stem = smoothstep(0.01, 0.0 , d + p.y*0.025);

                return max( m * strand * shade, stem);
            }

            fixed2 BendUV(fixed2 uv)    // old bending in 2d mode
            {
                uv -= fixed2(0, -0.45);
                fixed d = length(uv);
                uv = mul(uv, Rotate(sin(_Time.y * _Speed) * d));
                uv += fixed2(0, -0.45);
                return uv;
            }

            fixed3 Transform(fixed3 p, fixed angle)
            {
                p.xz = mul(p.xz, Rotate(angle));
                p.xy = mul(p.xy ,Rotate(angle *0.7));
                return p;
            }

            fixed4 FeatherBall(fixed3 ro, fixed3 rd, fixed3 pos, fixed angle)
            {
                fixed4 col = fixed4(0,0,0,0);

                fixed t = dot(pos - ro , rd);
                fixed3 p = ro + rd *t; // point of hit 
                fixed y = length(pos - p);  

                if(y < 1.0) // we have a hit
                {
                    fixed x = sqrt(1.0 - y);

                    fixed3 pF = ro + rd * (t-x) - pos; // front intersections
                    pF = Transform(pF , angle);
                    fixed2 uvF = fixed2(atan2(pF.x, pF.z), pF.y); // uv -pi<>+pi , -1<>+1
                    uvF *= fixed2(0.3,0.5);
                    fixed f = Feather(uvF);
                    fixed4 front = fixed4(fixed3(f,f,f), f);

                    fixed3 pB = ro + rd * (t+x) - pos; // back intersection
                    pB = Transform(pB , angle);
                    fixed2 uvB = fixed2(atan2(pB.x, pB.z), pB.y); 
                    uvB *= fixed2(0.3,0.5);
                    fixed b = Feather(uvB);
                    fixed4 back = fixed4(fixed3(b,b,b), b);

                    col = lerp(back, front , front.a);
                }

                return col;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv - 0.5) *_Scale;

                fixed4 col = lerp(_BGColorA, _BGColorB, uv.y+0.5);

                fixed3 ro = fixed3(0,0,-3);
                fixed3 rd = normalize(fixed3(uv,1));

                fixed speed = _Time.y * _Speed;
                
                for(fixed i = 0; i < 1.0; i+= 1.0/_MaxIter)
                {
                    fixed x = lerp(-_FeatherXRange, _FeatherXRange , frac(i+speed *0.1));
                    fixed y = lerp(-_FeatherYRange, _FeatherYRange , frac(sin(i *564.3)*498.38));
                    fixed z = lerp( 3.0, 0.0, i);

                    fixed4 feather = FeatherBall(ro, rd , fixed3(x,y,z), speed + i*563.34);
                    feather.rgb = sqrt(feather.rgb);
                    col = lerp(col , feather, feather.a);
                }

                col = pow(col , 0.456); // gamma correction

                return col;
            }

            ENDCG
        }
    }
}
