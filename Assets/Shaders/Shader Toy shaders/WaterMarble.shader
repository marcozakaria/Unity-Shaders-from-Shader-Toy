//https://www.shadertoy.com/view/WdXyDj
Shader "Unlit/WaterMarble"
{
    Properties
    {
        _Scale("Scale",float) = 20
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed _Scale;

            uint hash( uint x ) 
            {
                x += ( x << 10u );
                x ^= ( x >>  6u );
                x += ( x <<  3u );
                x ^= ( x >> 11u );
                x += ( x << 15u );
                return x;
            }

            uint hash( uint2 v ) 
            { 
                return hash( v.x ^ hash(v.y)); 
            }
            
            float floatConstruct( uint m ) 
            {
                const uint ieeeMantissa = 0x007FFFFFu; // binary32 mantissa bitmask
                const uint ieeeOne      = 0x3F800000u; // 1.0 in IEEE binary32

                m &= ieeeMantissa;                     // Keep only mantissa bits (fracional part)
                m |= ieeeOne;                          // Add fracional part to 1.0

                float  f = float( m );       // Range [1:2]
                return f - 1.0;                        // Range [0:1]
            }

            float random( float2  v ) 
            { 
                return floatConstruct(hash(uint2(v)));
            }

            float noise(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);

                // Four corners in 2D of a tile
                float a = random(i);
                float b = random(i + float2(1.0, 0.0));
                float c = random(i + float2(0.0, 1.0));
                float d = random(i + float2(1.0, 1.0));

                // Cubic Hermine Curve.  Same as SmoothStep()
                float2 u = f*f*(3.0-2.0*f);
                // u = smoothstep(0.,1.,f);

                // Mix 4 coorners percentages
                return lerp(a, b, u.x) +
                        (c - a)* u.y * (1.0 - u.x) +
                        (d - b) * u.x * u.y;
            }

            float noise( float2 uv, float detail)
            {
                float n = 0.;
                float m = 0.;

                for(float i = 0.; i < detail; i++)
                {
                    float x = pow(2., i);
                    float y = 1./x;
                    
                    n += noise(uv*x+y)*y;
                    m += y;
                }
                
                return n/m;               
            }

            float2x2 rot(float a)
            {
                float c = cos(a);
                float s = sin(a);
                return float2x2(c, -s, s, c);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv - 0.5 ) ;// (fragCoord-.5*iResolution.xy)/iResolution.y;
    
                uv *= _Scale;
                    
                float n = noise(uv,7.);
                uv = mul(uv, rot(n+_Time.y*.01)*n );
                
                fixed3 col = lerp(fixed3(0.,0.,.1),fixed3(0.,1.,1.),
                            noise(uv+_Time.y*fixed2(0.1,.6), 2.));

                // Output to screen
                //n = hash(uv);
                return fixed4(col,1.0);
            }
            
            ENDCG
        }
    }
}
