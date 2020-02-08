Shader "Unlit/StarFieldStars"
{
    Properties
    {
        _Speed("Speed",Range(0.01,5.0)) = 0.1
        _Scale("Scale",Range(1.0,50.0)) = 2.0
        _StarISize("Star Inner Size",Range(0.001,0.1)) = 0.05
        _StarCrossLines("Star Cross Lines Size",Range(1,1000)) = 1000
        _GlowDistance("Glow Distance",Range(0.01,1.5)) = 1.0
        _NumLayers("Number Of Layers",Range(1.0,20.0)) = 4.0
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

            fixed _Scale;
            fixed _Speed;
            fixed _StarISize;
            fixed _StarCrossLines;
            fixed _GlowDistance;
            fixed _NumLayers;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed2x2 Rot(fixed a)
            {
                fixed s = sin(a) , c = cos(a);
                return fixed2x2(c, -s ,s ,c);
            }

            fixed Star(fixed2 uv, fixed flare)
            {
                fixed d = length(uv); // distance to center
                fixed m = _StarISize/d;//smoothstep(0.1,0.05, d);

                fixed rays = max(0.0, 1.0-abs(uv.x*uv.y*_StarCrossLines));
                m += rays * flare;
                uv = mul(uv, Rot(3.1415/4.0)); // rot by 45 degrees
                rays = max(0.0, 1.0-abs(uv.x*uv.y*_StarCrossLines));
                m += rays * 0.3 * flare;

                m *= smoothstep(_GlowDistance,0.2, d); // fade star brightness from distance
                return m;
            }

            fixed Hash21( fixed2 p)
            {
                p = frac( p * fixed2(123.34, 456.21));
                p += dot(p, p+45.32);
                return frac(p.x * p.y);
            }

            fixed3 StarLayer(fixed2 uv)
            {
                fixed3 col = 0;

                fixed2 gv = frac(uv) - 0.5; // grid uv
                fixed2 id = floor(uv);

                for(int y= -1; y <= 1; y++)
                {
                    for(int x = -1; x <= 1; x++)
                    {
                        fixed2 offs = fixed2(x,y);

                        fixed n = Hash21(id + offs); // random between 0 and 1
                        fixed size = frac(n * 345.32);
                        
                        fixed star = Star(gv - offs - fixed2(n, frac(n * 34.0)) + 0.5, smoothstep(0.8,0.9,size));
                        fixed3 color = sin(fixed3(0.2,0.3,0.9) * frac(n*2345.2)*123.2) * 0.5 + 0.5;
                        color *= fixed3(1,0.5,1.+size);

                        star *= sin(_Time.y *3. + n * 6.2831) * 0.5 + 1.0; // twinkle effect
                        col += star * size * color;
                    }
                }

                return col;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv - 0.5) * _Scale;
                
                fixed3 col = 0;
                fixed time = _Time.y * _Speed;
                
                uv = mul(uv , Rot(time));
                for(fixed i=0; i <1.0; i+=1.0/_NumLayers)
                {
                    fixed depth = frac(i+time);

                    fixed scale = lerp(20.,0.5, depth);
                    fixed fade = depth * smoothstep(1.0,0.9, depth);
                    col += StarLayer(uv * scale + i*423.25) * fade;
                }
                // for debuging
                //if(gv.x > 0.48 || gv.y > 0.48) col.r = 1.0;

                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
