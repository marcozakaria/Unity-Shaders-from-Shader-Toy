// https://www.shadertoy.com/view/4lyXWW
Shader "Custom/FFT-IFS"
{
	Properties
    {
        MAX_ITER("Ray March max iterations",int) = 50
        //[Toggle(Make_fog)]_Use_fog("Make Fog",float) = 1

	    [HideInInspector]_MainTex ("MainTex", 2D) = "white" {}
	}

	SubShader
	{

        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

           // #pragma shader_feature Make_fog
            
            #include "UnityCG.cginc"

            struct VertexInput 
            {
                fixed4 vertex : POSITION;
                fixed2 uv:TEXCOORD0;
            };

            struct VertexOutput 
            {
                fixed4 pos : SV_POSITION;
                fixed2 uv:TEXCOORD0;
            };

            //Variables
            float4 _iMouse; //value to be changed by script
            sampler2D _MainTex;

            //#define MAX_ITER 20
            int MAX_ITER;

            fixed3x3 rotationMatrix(fixed3 axis, fixed angle)
            {
                fixed s = sin(angle);
                fixed c = cos(angle);
                fixed oc = 1.0 - c;

                return fixed3x3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                            oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                            oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
            }

            fixed udBox( fixed3 p, fixed3 b )
            {
                return length(max(abs(p)-b,0.0));
            }

            fixed3x3 ir;

            fixed DE(fixed3 p) 
            {
                fixed3 p_o = p;
                fixed d = 1e10;
                
                fixed s = 1.; //sin(_Time.y /60.0) / 10.0 + 0.6;
                fixed3 t = fixed3(0.1 + 0.2 * _iMouse.xy/1, 0.1 + 0.1 * sin(_Time.y/200.));
                
                fixed fftVal = tex2D(_MainTex,fixed2(length(p/5.), 0.2)).x *0.1;
                fixed3 dim = fixed3( fftVal, 0.9, fftVal);
                
                for ( int i = 0; i < 6; i ++)
                {
                    p -= t*s;
                    p = mul(ir , (p-t/s));
                    
                    //d = min	(d, udBox(p*s, dim/s) /s);
                    p = abs(p);
                                      
                    fixed circleSize = fftVal + 0.03 * (sin(_Time.y + length(p_o) * 5.) )
                        + 0.01;
                    d = min(d, length(p - t) - circleSize/s);
                    s *= s;                  
                }

                return d;
            }

            fixed lighting( in fixed3 ro, in fixed3 rd)
            {
                fixed res = 1.0;
                fixed t = 0.01;
                
                fixed k = 12.0;
                
                [unroll(100)]
                for( int i = 0; i < 2; i++ )
                {
                    fixed h = DE(ro + rd*t);
                    if( h<0.001 )
                        return 0.0;
                    
                    res = min( res,k * h/t );
                    t += h;
                }
                return res;
            }

            fixed3 gradient(fixed3 p) 
            {
                fixed2 e = fixed2(0., 0.0001);

                return normalize(
                    fixed3(
                        DE(p+e.yxx) - DE(p-e.yxx),
                        DE(p+e.xyx) - DE(p-e.xyx),
                        DE(p+e.xxy) - DE(p-e.xxy)
                    )
                );
            }

            //http://iquilezles.org/www/articles/fog/fog.htm
            fixed3 applyFog( in fixed3  rgb,      // original color of the pixel
                        in fixed distance, // camera to point distance
                        in fixed3  rayDir,   // camera to point fixedtor
                        in fixed3  sunDir )  // sun light direction
            {
                fixed b = .9 + 20.0 / fixed(MAX_ITER);
                fixed fogAmount = 1.0 - exp( -distance*b );
                fixed sunAmount = max( dot( rayDir, sunDir ), 0.0 );
                fixed3  fogColor  = lerp( fixed3(0.1,0.1,0.0), 
                                    fixed3(1.0,0.9,0.7),
                                    pow(sunAmount,8.0) );
                return lerp( rgb, fogColor, fogAmount );
            }

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(VertexOutput i) : SV_Target
            {
            
                fixed2 uv = i.uv / 1;
                uv -= 0.5;
                fixed aspect = 1/1;
                uv.x *= aspect;
                
                fixed3 cam = fixed3(0,0, - sin(_Time.y /32. ) - 3.0);
                fixed3 ray = normalize( fixed3(uv, 1.0));
                
                fixed3 color = fixed3(0.1, 0.1, 0.2);
                fixed3 p;
                fixed depth = 0.0;
                bool hit = false;
                fixed iter = 0.0;
                
                fixed fog = 0.0;
                fixed3 sun = normalize( fixed3(1,1,1));

                ir = rotationMatrix(normalize(fixed3(sin(_Time.y/50.0),sin(_Time.y/100.0),sin(_Time.y/150.0))), 1.5 + _Time.y/30.0);
                
                fixed3x3 mv = rotationMatrix(fixed3(0,1,0), _Time.y/10.0);
                    
                cam = mul(mv , cam);
                ray = mul(mv , ray);
                    
                [unroll(100)]
                for( int i= 0; i < MAX_ITER; i ++) 
                {
                        p = depth * ray + cam;
                        fixed dist = DE(p);
                        depth += dist * 0.9;                       
                        
                        if ( dist < 0.001)
                        {
                            hit = true;
                            break;                      
                        }
                    iter ++;
                }
                float fakeAO = 1.0 - iter / float(MAX_ITER);    
                float3 n = gradient(p);
                
                if (hit)
                {
                    float cTemp = fakeAO + dot(-ray,n) / 2.0;
                    color = float3(cTemp,cTemp,cTemp);
                }

                color = applyFog(color, depth, ray, sun);
                          
                //color *= vec3(1.0 - fog);
                color = pow(color, float3(0.6,0.6,0.6));

                return fixed4(color,1.0);
            }
            ENDCG
        }
    }
}

