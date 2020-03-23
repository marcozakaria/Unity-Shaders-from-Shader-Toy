// https://www.shadertoy.com/view/wsfcDM
Shader "Unlit/AnimeHitEffect"
{
    Properties
    {
        _Scale("Scale",Range(1.0,5.0)) = 2.0
        _Speed("Speed",Range(0.1,5.0)) = 1.0
        _Iteration("Iterations",Range(1, 5)) = 7
        _Color("Color",Color) = (1,0,0)
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

            #define ANIMATE 10.0
            #define INV_ANIMATE_FREQ 0.05
            #define RADIUS 1.3
            #define FREQ 10.0
            #define LENGTH 2.0
            #define SOFTNESS 0.1
            #define WEIRDNESS 0.1

            #define ASPECT_AWARE

            #define lofi(x,d) (floor((x)/(d))*(d))

            fixed _Scale, _Speed;
            int _Iteration;
            fixed3 _Color;

            fixed hash(fixed2 v ) // return random number
            {
                return frac( sin( dot( v, fixed2( 89.44, 19.36 ) ) ) * 22189.22 );
            }

            fixed iHash(fixed2 v, fixed2 r) 
            {
                fixed4 h = fixed4(
                    hash( fixed2( floor( v * r + fixed2( 0.0, 0.0 ) ) / r ) ),
                    hash( fixed2( floor( v * r + fixed2( 0.0, 1.0 ) ) / r ) ),
                    hash( fixed2( floor( v * r + fixed2( 1.0, 0.0 ) ) / r ) ),
                    hash( fixed2( floor( v * r + fixed2( 1.0, 1.0 ) ) / r ) )
                );

                fixed2 ip = fixed2(smoothstep(
                    fixed2(0.0,0.0 ),
                    fixed2(1.0,1.0 ),
                    fmod(v * r, 1.0 ) )
                );

                return lerp(
                    lerp(h.x, h.y, ip.y),
                    lerp(h.z, h.w, ip.y),
                    ip.x
                );
            }

            fixed noise(fixed2 v ) 
            {
                fixed sum = 0.0;
                for( int i = 1; i < _Iteration; i ++ ) 
                {
                    fixed value = 2.0 * pow( 2.0, fixed(i) );
                    sum += iHash(
                       v + fixed2( i, i ), fixed2(value, value) ) / pow( 2.0, fixed( i ) );
                }
                return sum;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uv = (i.uv-0.5) *_Scale;
                fixed2 puv = fixed2(
                    WEIRDNESS * length( uv ) + ANIMATE * lofi( _Time.y*_Speed, INV_ANIMATE_FREQ ),
                    FREQ * atan2( uv.x, uv.y)
                );

                fixed value = noise(puv );
                value = length(uv ) - RADIUS - LENGTH * (value - 0.5 );
                value = smoothstep( -SOFTNESS, SOFTNESS, value );
                return fixed4(_Color * value, value);
            }
            ENDCG
        }
    }
}
