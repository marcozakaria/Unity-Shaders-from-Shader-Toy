// https://www.shadertoy.com/view/XsfBzj
Shader "Unlit/RotatingCutCircles"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _Scale("Scale",float) = 300
        _Speed("Speed",Range(0.1,10.0)) = 0.05

        THR("ThresHold",Range(0.0,1.0)) = 0.5
        LOOPFREQ("loop frequency cuts",float) = 2.0
        ssThr("Smooth step ThresHold",float) = 2.0
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

            fixed THR ,LOOPFREQ, ssThr, _Scale,_Speed;
            fixed4 _Color;

            #define SCALE  0.1
            #define PI 3.14159265
            #define saturate(x) clamp(x,0.,1.)
            #define linearstep(a,b,x) saturate((x-a)/(b-a))

            fixed random2( fixed2 co ) // random number
            {
               return frac( sin( dot( co.xy, fixed2( 2.9898, 7.233 ) ) ) * 4838.5453 );
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 p = ( (i.uv-0.5) * _Scale  ) ;

                fixed radius = length( p ) * SCALE;
                fixed layerI = floor( radius );
                
                fixed theta = ( atan2( p.x, p.y ) + PI ) / 2.0 / PI;

                // make "ring"s
                fixed layerF = frac( radius );
                fixed ring = linearstep( 0.0, ssThr * SCALE, layerF );
                ring *= 1.0 - linearstep( 0.0, ssThr * SCALE, layerF - 0.3 );

                // define spinning velocity
                fixed vel = _Speed * ( random2( fixed2( layerI, 3.155 ) ) - 0.5 );

                // define number of segments
                fixed seg = 1.0+ floor( layerI * 4.0 * pow( random2( fixed2( layerI, 2.456 ) ), 2.0 ) );

                // define seeds
                fixed phase = frac( ( theta + _Time.y * vel ) * LOOPFREQ ) * seg;
                fixed seed = floor( phase ); // seed of current segment
                fixed seedN = fmod( seed + 1.0, seg ); // seed of next segment

                // calcurate state by seed and random
                fixed stateI = random2( fixed2( layerI, seed ) ) < THR ? 0.0 : 1.0;
                fixed stateIN = random2( fixed2( layerI, seedN ) ) < THR ? 0.0 : 1.0;

                // make gradient for next segment
                fixed state = lerp(
                    stateI,
                    stateIN,
                    linearstep( 0.0, ssThr / length( p ) * seg / PI, frac( phase ) )
                );

                fixed value = state * ring;
                return fixed4( _Color.rgb * value , _Color.a*value);
            }
            ENDCG
        }
    }
}
