Shader "Unlit/RayMarching StartingPoint"
{
    Properties
    {
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ro : TEXCOORD1; // rayorigin
                float3 hitPos : TEXCOORD2;
            };

            int _MaxSteps, _MaxDist;
            float _SURF_DIST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
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

            float GetDistBox(float3 p, float3 s) // s for size
            {
                return length(max(0.0, abs(p)-s));
            }

            float GetDistGyroid(float3 p, float scale, float thickness, float bias)
            {
                p *= scale;
                return abs(dot(sin(p), cos(p.zxy))+bias)/scale - thickness;
            }

            float GetDist(float3 p)  // Signed Distance functions
            {
                float boxDist = GetDistBox(p, float3(0.5,0.5,0.5));

                float gyroid = GetDistGyroid(p , 20.0 , 0, 0.5); //dot(sin(p), cos(p.zxy)) / 15.0;
                float d = max(boxDist,gyroid*0.2);
                return d;
            }

            float RayMarch(float3 rayOrigin, float3 rayDirection)
            {
                float dO = 0; // distance from origin, distance travelled
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
