// converted from shader toy https://www.shadertoy.com/view/4dl3zn

Shader "Custom/Bubble Circle Shader"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        // Shader Controlles
        _Iterations("Number of cicles", int) = 40
        _SizeMultiplayer("Size random Multiplier",Range(0.01,1.0)) = 0.5
        _MinimumSize("Minimum circle Size",Range(0.0,0.3)) = 0.1

        _ColorA("Color A", Color) = (0.94,0.3,0.0,0)
        _ColorB("Color B", Color) = (0.1,0.4,0.8,0)

        [Toggle(MAKE_EDGE)]_IsEdge("Circle Edge", Float) = 0
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
            // for boolean to work
            #pragma shader_feature MAKE_EDGE

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            int _Iterations;
            float _SizeMultiplayer;
            float _MinimumSize;

            fixed4 _ColorA;
            fixed4 _ColorB;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
               
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = -1.0 + 2.0*i.vertex.xy / _ScreenParams.xy;
	            uv.x *= _ScreenParams.x / _ScreenParams.y;

                // background	 
	            float3 color = float(0.8 + 0.2*uv.y);

                // bubbles	
	            for( int i=0; i < _Iterations; i++ ) // i for how many circles
	            {
                    // bubble random seeds
		            float pha = sin(float(i)*546.13+1.0)*0.5 + 0.5;
		            float size = pow(sin(float(i)*651.74+5.0)*0.5 + 0.5, 4.0);
		            float pox = sin(float(i)*321.55+4.1) * _ScreenParams.x / _ScreenParams.y;

                    // bubble size, position and color
		            float rad = _MinimumSize + _SizeMultiplayer * size;
		            float2 pos = float2( pox, -1.0-rad + (2.0+2.0*rad) * fmod(pha+0.1*_Time.y*(0.2+0.8*size),1.0));
		            float dis = length( uv - pos );
		            float3 col = lerp( _ColorA, _ColorB, 0.5+0.5*sin(float(i)*1.2+1.9));
		         
                    #ifdef MAKE_EDGE
                        col+= 8.0*smoothstep( rad*0.95, rad, dis );
                    #endif
                    
                    // render
		            float f = length(uv-pos)/rad;
		            f = sqrt(clamp(1.0-f*f,0.0,1.0));
		            color -= col.zyx *(1.0-smoothstep( rad*0.95, rad, dis )) * f;
	            }

                // vigneting	
	            //color *= sqrt(1.5-0.5*length(uv));
                fixed4 col = float4(color.x,color.y,color.z,1.0);
                //col = mul(color,color);
                
                return col;
            }
            ENDCG
        }
    }
}
