// https://www.shadertoy.com/view/wdlyzS
Shader "Unlit/Cell"
{
    Properties
    {
       _scale("Scale",float) = 1
       _scaleCell("Cell Scale",float) = 25
       _cellMinDist("Cell Min Dist", Range(0.1,1.0)) = 0.80
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

            fixed _scale,_scaleCell , _cellMinDist;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed2 random (fixed2 _st) 
            {
                _st = fixed2(dot(_st, fixed2(12.9898,78.233)), dot(_st, fixed2(13.9898,124.233)));
                return frac(sin(_st)* 43758.5453123);
            }

            fixed circle(fixed2 _uv)
            {
                fixed dist = length(fixed2(_uv.x , _uv.y) - fixed2(0.5 , 0.5));
                return dist;
            }

            /*fixed circle2(fixed2 uv)
            {
                fixed dist = length(fixed2(uv.x , uv.y) - fixed2(0.5 , 0.5));
                return dist;
            }

            fixed circle3(fixed2 uv)
            {
                fixed dist = length(fixed2(uv.x , uv.y) - fixed2(0.5 , 0.5));
                return dist;
            }*/

            fixed4 frag (v2f i) : SV_Target
            {  
                fixed2 st = i.uv * _scaleCell; // voranoi cell scale
                fixed2 uv = i.uv *_scale;

                // Tile the space
                fixed2 i_st = floor(st);
                fixed2 f_st = frac(st);               
                
                fixed2 point1 = random(i_st);               
            
                //loop over neighbour for nearest
                for (int y= -1; y <= 1; y++)
                 {
                    for (int x= -1; x <= 1; x++) 
                    {
                        // Neighbor place in the grid
                        fixed2 neighbor = fixed2(fixed(x),fixed(y));

                        // Random position from current + neighbor place in the grid
                        fixed2 point1 = random(i_st + neighbor);

                        // Animate the point1
                        point1 = 0.5 + 0.5*sin(_Time.y/1.5 + 6.99999 * point1);

                        // Vector between the pixel and the point1
                        fixed2 diff = neighbor + point1 - f_st;

                        // Distance to the point1
                        fixed dist = length(diff);

                        // Keep the closer distance
                        _cellMinDist = min(_cellMinDist, sqrt(dist));
                    }
                }
                
                //tweak lighting                
                _cellMinDist += 0.1;
                
                //urgh at this hard coding                
                fixed circ = smoothstep(0.675, 0.695, 1.0 - circle(uv));
                
                //fixed circ2 = smoothstep(0.69, 0.695, 1.0 - circle(uv)) - smoothstep(0.70, 0.7050, 1.0 - circle(uv));
                
                //fixed circ3 = smoothstep(1.0 - 0.68,1.0 - 0.67,circle(uv));
                
                fixed3 color = fixed3(_cellMinDist + 0.05,_cellMinDist, _cellMinDist);              
                
                //color *= circ;
                //color -= 0.2 * circ2;
                
                //color += circ3;   
                    
                return fixed4(color,circ);
            }
            ENDCG
        }
    }
}
