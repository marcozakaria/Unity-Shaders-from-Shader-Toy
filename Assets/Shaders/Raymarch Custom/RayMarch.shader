Shader "Unlit/RayMarch"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _MaxSteps("Max Steps",int) = 100
        _MaxDist("Max Distance",int) = 100
        _SURF_DIST("Min Surf Distance",float) = 0.001
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

            //#define Max_Steps 100
            //#define Max_Dist 100
           // #define SURF_DIST 1e-3 // 0.001

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f // vertex to frament
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ro : TEXCOORD1; // rayorigin
                float3 hitPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            int _MaxSteps;
            int _MaxDist;
            float _SURF_DIST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // object space
                o.ro = mul(unity_WorldToObject , float4(_WorldSpaceCameraPos,1));
                o.hitPos = v.vertex;  
                // world space
               //o.ro = _WorldSpaceCameraPos;
                //o.hitPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            // multiple it with 2 axis we want to rotate on
            float2x2 Rotate(float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                return float2x2(c, -s, s, c);
            }

            float MandleBulb(float3 pos) 
            {
                int Power = 4;

                float3 z = pos;
                float dr = 1.0;
                float r = 0.0;
                for (int i = 0; i < 15 ; i++) 
                {
                    r = length(z);
                    if (r>2) break;
                    
                    // convert to polar coordinates
                    float theta = acos(z.z/r) *Power;
                    float phi = atan2(z.x,z.y) * Power;
                    dr =  pow( r, Power-1.0)*Power*dr + 1.0;
                    
                    // scale and rotate the point
                    float zr = pow( r,Power);
                    theta = theta*Power;
                    phi = phi*Power;
                    
                    // convert back to cartesian coordinates
                    z = zr*float3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
                    z+=pos;
                }
                return 0.5*log(r)*r/dr;
            }

            float GetDistSphere(float3 p, float radius)
            {
                float d = length(p) - radius; // sphere , radius  = 0.5
                return d; 
            }

            float GetDistCapsule(float3 p, float3 a, float3 b, float radius) 
            {
                float3 ab = b-a;
                float3 ap = p-a;

                float t = dot(ab,ap) / dot(ab,ab);
                t = clamp(t,0.0,1.0); 

                float3 c = a + t*ab;
                return (length(p-c) - radius);
            }

            float GeDisttPrism(float3 p, float3 centre, float2 h) // triangle
            {
                float3 q = abs(p - centre);
                return max(q.z - h.y, max(q.x * 0.866025 + p.y * 0.5, -p.y) - h.x * 0.5);
            }

            float GetDistCylinder(float3 p, float3 a, float3 b, float radius) 
            {
                float3 ab = b-a;
                float3 ap = p-a;

                float t = dot(ab,ap) / dot(ab,ab);
                //t = clamp(t,0.0,1.0); // commneting this part making cylender tall is infinite

                float3 c = a + t*ab;
                float x = (length(p-c) - radius);
                float y = (abs(t-0.5)-0.5) * length(ab);
                float e = length(max(float2(x,y),0.0));
                float i = min(max(x,y),0.0); // interior distance
                return e+i;
            }

            float GetDistBox(float3 p, float3 s) // s for size
            {
                return length(max(0.0, abs(p)-s));
            }

            float GetDistTorus(float3 p,float r1, float r2)
            {
                float d = length( float2( length(p.xz) - r1 , p.y)) - r2; // torus
                return d; 
            }

            // when object go inside object and we cut the part of B from A
            float BooleanSubstractionDist(float distA, float distB)
            {
                return max(-distA, distB);
            }

            float BooleanIntersectionDist(float distA, float distB)
            {
                return max(distA, distB);
            }

            float BooleanUnionDist(float distA, float distB)
            {
                return min(-distA, distB);
            }

            float SmoothMinimum(float distA, float distB, float k)
            {
                float h = clamp(0.5 + 0.5*(distB-distA)/k, 0.0 , 1.0);
                return (lerp(distB, distA, h) - k*h*(1.0-h));
            }

            float GetDist(float3 p)
            {
                float sphereDist = GetDistSphere(p - float3(-2,1,0),1.0);
                float planeDist = p.y;

                float3 boxPos = p - float3(-2 , 1 ,0);
                boxPos.xz = mul(boxPos.xz, Rotate(_Time.y)); // rotation on XZ is rotatiing on Y axis
                float boxDist = GetDistBox(boxPos,float3(0.5,0.5,0.5));

                float torusDist = GetDistTorus(p -float3(2,0.5,-1),0.8,0.2);
                float capsuleDist = GetDistCapsule(p,float3(0,1,0),float3(0,2,0),0.3);
                float cylinderDist = GetDistCylinder(p,float3(0,0.3,2),float3(0,1.7,2),0.35);
                float prismDist = GeDisttPrism(p, float3(1, 0.5, -1.5), float2(1.5, 0.5));

                float d;
                d = lerp(sphereDist, boxDist, sin(_Time.y)*0.5+0.6); // moorf distance
                d = min(capsuleDist, d);
                //d = min(boxDist, d);               
                d = min(planeDist, d);
                d = min(cylinderDist, d);
                d = min(torusDist, d);
                d = SmoothMinimum(prismDist, d, 0.8);
                
                return d;
            }

            float RayMarch(float3 rayOrigin, float3 rayDirection)
            {
                float dO = 0; // distance from origin
                float ds; // distance from scene
                for(int i =0; i < _MaxSteps; i++)
                {
                    float3 p = rayOrigin + dO * rayDirection; // raymarching position
                    ds = GetDist(p); //MandleBulb(p);
                    dO += ds;
                    if(ds < _SURF_DIST || dO > _MaxDist) break; // if hit or passed maximum distance
                }

                return dO;
            }           

            float3 GetNormal(float3 p)
            {
                float2 e = float2(1e-2, 0);
                // get dist will be custo mized to each shape
                float3 n = GetDist(p) - float3(
                    GetDist(p-e.xyy),
                    GetDist(p-e.yxy),
                    GetDist(p-e.yyx)
                    );

                return normalize(n);
            }

            float GetLight(float3 p) 
            {
                float3 lightPos = float3(0, 5, 6);
                lightPos.xz += float2(sin(_Time.y), cos(_Time.y))*2.;
                float3 l = normalize(lightPos-p);
                float3 n = GetNormal(p);
                
                float dif = clamp(dot(n, l), 0., 1.);
                float d = RayMarch(p+n *_SURF_DIST *2., l);
                if(d<length(lightPos-p)) dif *= .1;
                
                return dif;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv - 0.5; // -0.5 to make uv start at center
                float3 rayOrigin = i.ro; //float3(0,0,0.3);
                float3 rayDirection = normalize(i.hitPos - rayOrigin); //normalize(float3(uv.x,uv.y,1));

                float d = RayMarch(rayOrigin,rayDirection);
                fixed4 col = 0;

                if(d < _MaxDist) // hit the surface
                {
                    float3 p = rayOrigin + rayDirection * d;
                    float3 n = GetLight(p);//GetNormal(p);
                    col.rgb = n;
                }
                else{ discard;} // discard dont render this pixel at all

                //col.rgb = rayDirection;
                return col;
            }
            ENDCG
        }
    }
}
