Shader "Unlit/RayMarch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            #define Max_Steps 100
            #define Max_Dist 100
            #define SURF_DIST 1e-3 // 0.001

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

            float GetDistCapsule(float3 p, float3 a, float3 b, float radius) // not working
            {
                float3 ab = b-a;
                float3 ap = p-a;

                float t = dot(ab,ap) / dot(ap,ab);
                t = clamp(t,0.0,1.0); 

                float3 c = a + t*ab;
                return (length(p-c) - radius);
            }

            float GetDistBox(float3 p)
            {
                return 0.0;
            }

            float GetDistTorus(float3 p,float r1, float r2)
            {
                float d = length( float2( length(p.xz) - r1 , p.y)) - r2; // torus
                return d; 
            }

            float GetDist(float3 p)
            {
                float4 s = float4(0,1,0,1);

                float sphereDist = GetDistSphere(p - s.xyz,s.w);
                float planeDist = p.y;
                float torusDist = GetDistTorus(p -s,0.8,0.2);
                float capsuleDist = GetDistCapsule(p,float3(0,1,0),float3(0,2,0),0.3);

                float d = min(capsuleDist,planeDist);
                return d;
            }

            float RayMarch(float3 rayOrigin, float3 rayDirection)
            {
                float dO = 0; // distance from origin
                float ds; // distance from scene
                for(int i =0; i < Max_Steps; i++)
                {
                    float3 p = rayOrigin + dO * rayDirection; // raymarching position
                    ds = GetDist(p); //MandleBulb(p);
                    dO += ds;
                    if(ds < SURF_DIST || dO > Max_Dist) break; // if hit or passed maximum distance
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

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv - 0.5; // -0.5 to make uv start at center
                float3 rayOrigin = i.ro; //float3(0,0,0.3);
                float3 rayDirection = normalize(i.hitPos - rayOrigin); //normalize(float3(uv.x,uv.y,1));

                float d = RayMarch(rayOrigin,rayDirection);
                fixed4 col = 0;

                if(d < Max_Dist) // hit the surface
                {
                    float3 p = rayOrigin + rayDirection * d;
                    float3 n = GetNormal(p);
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
