// https://www.shadertoy.com/view/WtyXzR
Shader "Unlit/Noise Waves"
{
    Properties
    {
       _NoiseSpeed("Noise Speed",Range(0.0,10)) = 2 
       _NoiseScale("Noise Scale",Range(1,1024)) = 32
       _NoiseBlend("Noise Blend",Range(0.0,1.0)) = 0.4 

       _WaveSpeed("Wave Speed",Range(0,10)) = 0.5 
       _WaveLength("Wave Length",Range(0,50)) = 10
       _TransprencyPercent("Tranprency Percent",Range(0.0,1.0)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        LOD 100
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha

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

            fixed _NoiseSpeed, _NoiseScale, _NoiseBlend;
            fixed _WaveLength, _WaveSpeed;
            fixed _TransprencyPercent;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed Hash21(fixed2 v) 
            {
                return frac(sin(dot(v.xy, fixed2(37.8479, 84.1047))) * 23479.34593785 + frac(_Time.y*_NoiseSpeed));
            }

            fixed4 frag (v2f i) : SV_Target
            {  
                fixed2 uv = i.uv;
                fixed2 noiseUV = uv*_NoiseScale;
                noiseUV = floor(noiseUV);

                fixed waveColSingle = sin(noiseUV.y/_WaveLength + _Time.y*_WaveSpeed)*.5+.5;
                fixed3 waveCol = fixed3(waveColSingle, waveColSingle, waveColSingle);
                fixed noiseColSingle = Hash21(noiseUV);
                fixed3 noiseCol = fixed3(noiseColSingle, noiseColSingle, noiseColSingle);
                
                fixed3 col = lerp(waveCol, noiseCol, _NoiseBlend);
                if(noiseColSingle < _TransprencyPercent)
                {
                    discard;
                }
                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
