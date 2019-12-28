//https://www.shadertoy.com/view/Mts3zM
Shader "Custom/simple"
{

	Properties
    {
        _Speed("Speed",Range(0.1,5)) = 1.5
        _LineCount("Line Count",Range(1,50)) = 20
        [Toggle(COLORED)] _COLORED("Colored", Float) = 1
        [Toggle(MIRROR)] _MIRROR("Mirror", Float) = 1
        [Toggle(ROT_OFST)] _ROT_OFST("Rotation Offset", Float) = 1
        [Toggle(TRIANGLE_NOISE)] _TRIANGLE_NOISE("Triangle Noise", Float) = 1
        [Toggle(SHOW_TRIANGLE_NOISE_ONLY)] _SHOW_TRIANGLE_NOISE_ONLY("Show Triangle noise only", Float) = 0
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
        #include "UnityCG.cginc"

        struct VertexInput 
        {
            fixed4 vertex : POSITION;
            fixed2 uv:TEXCOORD0;
            fixed4 tangent : TANGENT;
            fixed3 normal : NORMAL;
        };

        struct VertexOutput 
        {
            fixed4 pos : SV_POSITION;
            fixed2 uv:TEXCOORD0;
        };

        //Variables
        fixed _Speed;
        fixed _LineCount;

        //This might look like a lot of code but the base implementation of the gif itself is ~10loc

        #define time _Time.y * _Speed
        #define pi 3.14159265

        //#define NUM 20.
        #define PALETTE fixed3(.0, 1.4, 2.)+1.5

        #pragma shader_feature COLORED
        #pragma shader_feature MIRROR
        //#define ROTATE
        #pragma shader_feature ROT_OFST
        #pragma shader_feature TRIANGLE_NOISE

        #pragma shader_feature SHOW_TRIANGLE_NOISE_ONLY

        fixed2x2 mm2(in fixed a){fixed c = cos(a), s = sin(a);return fixed2x2(c,-s,s,c);}
        fixed tri(in fixed x){return abs(frac(x)-.5);}
        fixed2 tri2(in fixed2 p){return fixed2(tri(p.x+tri(p.y*2.)),tri(p.y+tri(p.x*2.)));}
        fixed2x2 m2 = fixed2x2( 0.970,  0.242, -0.242,  0.970 );

        //Animated triangle noise, cheap and pretty decent looking.
        fixed triangleNoise(in fixed2 p)
        {
            fixed z=1.5;
            fixed z2=1.5;
            fixed rz = 0.;
            fixed2 bp = p;
            for (fixed i=0.; i<=3.; i++ )
            {
                fixed2 dg = tri2(bp*2.)*.8;
                dg = mul(dg,mm2(time*.3));
                p += dg/z2;

                bp *= 1.6;
                z2 *= .6;
                z *= 1.8;
                p *= 1.2;
                p= mul(p,m2);
            
                rz+= (tri(p.x+tri(p.y)))/z;
            }
            return rz;
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
            fixed aspect = 1;// _ScreenParams.x/_ScreenParams.y;
            fixed w = 50./ sqrt(_ScreenParams.x*aspect+_ScreenParams.y); //sqrt(1*aspect+1);

            fixed2 p = i.uv / 1*2.-1.;
            p.x *= aspect;
            p*= 1.05;
            fixed2 bp = p;
        
            #ifdef ROTATE
            p *= mm2(time*.25);
            #endif
        
            fixed lp = length(p);
            fixed id = floor(lp*_LineCount+.5)/_LineCount;
        
            #ifdef ROT_OFST
            p =mul(p, mm2(id*11.));
            #endif
        
            #ifdef MIRROR
            p.y = abs(p.y); 
            #endif
        
            //polar coords
            fixed2 plr = fixed2(lp, atan2( p.x,p.y));
        
            //Draw concentric circles
            fixed rz = 1.-pow(abs(sin(plr.x*pi*_LineCount))*1.25/pow(w,0.25),2.5);
        
            //get the current arc length for a given id
            fixed enp = plr.y+sin((time+id*5.5))*1.52-1.5;
            rz *= smoothstep(0., 0.05, enp);
        
            //smooth out both sides of the arcs (and clamp the number)
            rz *= smoothstep(0.,.022*w/plr.x, enp)*step(id,1.);
            #ifndef MIRROR
            rz *= smoothstep(-0.01,.02*w/plr.x,pi-plr.y);
            #endif
        
            #ifdef TRIANGLE_NOISE
            rz *= (triangleNoise(p/(w*w))*0.9+0.4);
            fixed3 col = (sin(PALETTE+id*5.+time)*0.5+0.5)*rz;
            col += smoothstep(.4,1.,rz)*0.15;
            col *= smoothstep(.2,1.,rz)+1.;
        
            #else
            fixed3 col = (sin(PALETTE+id*5.+time)*0.5+0.5)*rz;
            col *= smoothstep(.8,1.15,rz)*.7+.8;
            #endif
        
            #ifndef COLORED
            col = (dot(col,fixed3(0.7,0.7,0.7)));
            #endif
        
            #ifdef SHOW_TRIANGLE_NOISE_ONLY
            col = fixed3(triangleNoise(bp),triangleNoise(bp),triangleNoise(bp));
            #endif
        
            return fixed4(col,1.0);
        }
    ENDCG
	}
  }
}

