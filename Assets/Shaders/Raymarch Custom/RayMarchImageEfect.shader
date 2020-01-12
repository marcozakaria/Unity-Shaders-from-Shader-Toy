Shader "ImageEffect/RayMarchImageEfect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            // uniform like public
            uniform sampler2D _CameraDepthTexture;
            uniform float4x4 _CamFrustum, _CamToWorld;
            uniform float _maxDistance;
            uniform float3 _LightDir;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ray : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                half index = v.vertex.z;
                v.vertex.z = 0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.ray = _CamFrustum[(int)index].xyz;
                o.ray /= abs(o.ray.z); // normalize
                o.ray = mul(_CamToWorld , o.ray);

                return o;
            }

            float GetDistBox(float3 p, float3 s) // s for size
            {
                return length(max(0.0, abs(p)-s));
            }

            float SDSphere(float3 p , float r)
            {
                return length(p) - r;
            }

            float GetDistanceField(float3 p)
            {
                float sphere1 = SDSphere(p - float3(0,0,0), 1.0);
                float box1 = GetDistBox(p - float3(2,1,0),float3(1,1,1));
                return sphere1;
            }

            float3 GetNormal(float3 p)
            {
                const float2 offset = float2(0.001, 0.0);
                float3 n = float3(
                    GetDistanceField(p+ offset.xyy) - GetDistanceField(p- offset.xyy),
                    GetDistanceField(p+ offset.yxy) - GetDistanceField(p- offset.yxy),
                    GetDistanceField(p+ offset.yyx) - GetDistanceField(p- offset.yyx)
                );
                return normalize(n);
            }

            fixed4 Raymarching(float3 ro, float3 rd, float depth)
            {
                fixed4 result = fixed4(1,1,1,1);
                const int maxIteration = 64;

                float distanceTravelled = 0; //t distance travelled along the ray direction

                for(int i=0; i < maxIteration; i++)
                {
                    if(distanceTravelled > _maxDistance || distanceTravelled >= depth)
                    {
                        // enviroment
                        result = fixed4(rd,0);
                        break;
                    }
                    
                    float3 p = ro + rd * distanceTravelled;
                    // check for hit in
                    float d = GetDistanceField(p);
                    if(d < 0.01)// we hit something
                    {
                        //Shading
                        float3 n = GetNormal(p);
                        float light = dot(-_LightDir,n);
                        result = fixed4(fixed3(1,1,1)* light,1) ;
                        break;
                    }
                    
                    distanceTravelled += d;
                }

                return result;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = LinearEyeDepth(tex2D(_CameraDepthTexture,i.uv).r);
                depth *= length(i.ray);
                fixed3 col = tex2D(_MainTex, i.uv);

                float3 rayDirection = normalize(i.ray.xyz);
                float3 rayOrigin = _WorldSpaceCameraPos;
                fixed4 result = Raymarching(rayOrigin,rayDirection,depth);

                return fixed4(col*(1.0 - result.w) + result.xyz*result.w ,1.0);
            }
            ENDCG
        }
    }
}
