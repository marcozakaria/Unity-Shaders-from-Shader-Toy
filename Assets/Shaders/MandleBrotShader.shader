// From Art of code series
Shader "Custom/MandleBrotShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Area("Area", vector) = (0,0,4,4)
        _Angle("Angle",Range(0.0,20.0)) = 0.0
        _MaxIter("Max Iterations",float) = 255
        _Color("Color",Range(0.0,1.0)) = 0.5
        _Repeat("Repeat" , float) = 1.0
        _EscapeRadius("Escape Radius",Range(1.0,100.0)) = 20.0
        _Speed("Speed" , float) = 1.0
        _RotSpeed("Rot Speed" , float) = 1.0
        _LeavesISpeed("Leaves line Speed" , float) = 4.0
        _Symmetry("Symmetry",Range(0.0,1.0)) = 0.0
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Area;
            float _Angle,_MaxIter;

            float _Color;
            float _Repeat;

            float _EscapeRadius;
            float _Speed;
            float _RotSpeed;
            float _LeavesISpeed;

            float _Symmetry;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            // rotate a pixel , p for point we want to rotate , angle to rotate with
            float2 Rotate(float2 p,float2 pivot, float a)
            {
                float s = sin(a);
                float c = cos(a);

                p -= pivot;
                p = float2(p.x*c - p.y*s, p.x*s + p.y*c);
                p += pivot;

                return p;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv-0.5;
                uv = abs(uv);
                uv = Rotate(uv , 0 , 0.25*3.1415);
                uv = abs(uv);

                uv = lerp(i.uv-0.5, uv , _Symmetry);

                float2 c = _Area.xy + (uv)*_Area.zw; // start position
                c = Rotate(c,_Area.xy,_Angle);

                float r = _EscapeRadius; // escape radius
                float r2 = r*r;

                float2 z,zPrevious; // to keep track of current pixel
                float iter;
                for(iter = 0; iter < _MaxIter; iter++)
                {
                    zPrevious = Rotate(z, 0, _Time.y*_RotSpeed);
                    z = float2(z.x*z.x - z.y*z.y, 2*z.x*z.y) + c;
                    
                    if(dot(z,zPrevious) > r2) break; // distance from origin
                }
                if(iter > _MaxIter) return 0;
                
                float dist = length(z); // distance from origin
                float fractIter = (dist-r) / (r2-r); // linear interpolation
                fractIter = log2(log(dist) / log(r) ); // double exponential interpolation 

                //iter -= fractIter; // smooth iteration

                float m = sqrt(iter/_MaxIter);
                float4 col = sin(float4(0.3,0.45,0.65,1.0)*m*20) * 0.5+0.5; // procedural color
                col = tex2D(_MainTex , float2(m*_Repeat + _Time.y*_Speed,_Color)); // texture color
                
                float angle = atan2(z.x,z.y); // -pi and pi
                col *= smoothstep(3,0,fractIter);

                col *= 1 + sin(angle * 2 +_Time.y*_LeavesISpeed)*0.2;
                return col;
            }
            ENDCG
        }
    }
}
