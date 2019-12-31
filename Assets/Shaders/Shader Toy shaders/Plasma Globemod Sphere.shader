// https://www.shadertoy.com/view/MldczX
Shader "Custom/Plasma Globemod"
{

	Properties
    {
	    _MainTex ("MainTex", 2D) = "white" {}
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
        float4 _iMouse;
        sampler2D _MainTex;

	        // Fork of "Plasma Globe" by nimitz. https://shadertoy.com/view/XsjXRm
        // 2018-08-06 04:31:13

        //Plasma Globe by nimitz (twitter: @stormoid)

        //looks best with around 25 rays
        #define NUM_RAYS 33.

        #define VOLUMETRIC_STEPS 19

        #define MAX_ITER 35
        #define FAR 6.

        #define time _Time.y*1.1

        fixed2x2 mm2(in fixed a){fixed c = cos(a), s = sin(a);return fixed2x2(c,-s,s,c);}
        fixed noise( in fixed x ){return tex2Dlod(_MainTex,float4( fixed2(x*.01,1.),0.0,0)).x;}

        fixed hash( fixed n ){return frac(sin(n)*43758.5453);}

        //iq's ubiquitous 3d noise
        fixed noise(in fixed3 p)
        {
	        fixed3 ip = floor(p);
            fixed3 f = frac(p);
	        f = f*f*(3.0-2.0*f);
	
	        fixed2 uv = (ip.xy+fixed2(37.0,17.0)*ip.z) + f.xy;
	        fixed2 rg = tex2Dlod( _MainTex,float4( (uv+ 0.5)/256.0, 0.0 ,0)).yx;
	        return lerp(rg.x, rg.y, f.z);
        }

        fixed3x3 m3 = fixed3x3( 0.00,  0.80,  0.60,
                      -0.80,  0.36, -0.48,
                      -0.60, -0.48,  0.64 );

        //See: https://www.shadertoy.com/view/XdfXRj
        fixed flow(in fixed3 p, in fixed t)
        {
	        fixed z=2.;
	        fixed rz = 0.;
	        fixed3 bp = p;
	        for (fixed i= 1.;i < 5.;i++ )
	        {
		        p += time*.1;
		        rz+= (sin(noise(p+t*0.8)*6.)*0.5+0.5) /z;
		        p = lerp(bp,p,0.6);
		        z *= 2.;
		        p *= 2.01;
                p = mul(p , m3);
	        }
	        return rz;	
        }

        //could be improved
        fixed sins(in fixed x)
        {
 	        fixed rz = 0.;
            fixed z = 2.;
            for (fixed i= 0.;i < 3.;i++ )
	        {
                rz += abs(frac(x*1.4)-0.5)/z;
                x *= 1.3;
                z *= 1.15;
                x -= time*.65*z;
            }
            return rz;
        }

        fixed segm( fixed3 p, fixed3 a, fixed3 b)
        {
            fixed3 pa = p - a;
	        fixed3 ba = b - a;
	        fixed h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1. );	
	        return length( pa - ba*h )*.5;
        }

        fixed3 path(in fixed i, in fixed d)
        {
            fixed3 en = fixed3(0.,0.,1.);
            fixed sns2 = sins(d+i*0.5)*0.22;
            fixed sns = sins(d+i*.6)*0.21;
            en.xz = mul(en.xz, mm2((hash(i * 10.569) - .5) * 6.2 + sns2));//*= mm2((hash(i*10.569)-.5)*6.2+sns2);
            en.xy = mul(en.xy, mm2((hash(i * 4.732) - .5) * 6.2 + sns));// *= mm2((hash(i * 4.732) - .5) * 6.2 + sns);
            return en;
        }

        fixed2 map(fixed3 p, fixed i)
        {
	        fixed lp = length(p);
            fixed3 bg = fixed3(0.,0.,0.);   
            fixed3 en = path(i,lp);
    
            fixed ins = smoothstep(0.11,.46,lp);
            fixed outs = .15+smoothstep(.0,.15,abs(lp-1.));
            p *= ins*outs;
            fixed id = ins*outs;
    
            fixed rz = segm(p, bg, en)-0.011;
            return fixed2(rz,id);
        }

        fixed march(in fixed3 ro, in fixed3 rd, in fixed startf, in fixed maxd, in fixed j)
        {
	        fixed precis = 0.001;
            fixed h=0.5;
            fixed d = startf;
            [unroll(100)]
            for( int i=0; i<MAX_ITER; i++ )
            {
                if( abs(h)<precis||d>maxd ) break;
                d += h*1.2;
	            fixed res = map(ro+rd*d, j).x;
                h = res;
            }
	        return d;
        }

        //volumetric marching
        fixed3 vmarch(in fixed3 ro, in fixed3 rd, in fixed j, in fixed3 orig)
        {   
            fixed3 p = ro;
            fixed2 r = fixed2(0.,0.);
            fixed3 sum = fixed3(0,0,0);
            fixed w = 0.;
            [unroll(100)]
            for( int i=0; i<VOLUMETRIC_STEPS; i++ )
            {
                r = map(p,j);
                p += rd*.03;
                fixed lp = length(p);
        
                fixed3 col = sin(fixed3(1.05,2.5,1.52)*3.94+r.y)*.85+0.4;
                col.rgb *= smoothstep(.0,.015,-r.x);
                col *= smoothstep(0.04,.2,abs(lp-1.1));
                col *= smoothstep(0.1,.34,lp);
                sum += abs(col)*5. * (1.2-noise(lp*2.+j*13.+time*5.)*1.1) / (log(distance(p,orig)-2.)+.75);
            }
            return sum;
        }

        //returns both collision dists of unit sphere
        fixed2 iSphere2(in fixed3 ro, in fixed3 rd)
        {
            fixed3 oc = ro;
            fixed b = dot(oc, rd);
            fixed c = dot(oc,oc) - 1.;
            fixed h = b*b - c;
            if(h <0.0) return fixed2(-1.,-1.);
            else return fixed2((-b - sqrt(h)), (-b + sqrt(h)));
        }

	    VertexOutput vert (VertexInput v)
	    {
	        VertexOutput o;
	        o.pos = UnityObjectToClipPos (v.vertex);
	        o.uv = v.uv;
	        //VertexFactory
	        return o;
	    }

	    fixed4 frag(VertexOutput i) : SV_Target
        {
            fixed2 p = i.uv / 1 - 0.5;
            p.x *= 1 / 1;
            fixed2 um = _iMouse.xy / 1 - .5;

            //camera
            fixed3 ro = fixed3(0.,0.,5.);
            fixed3 rd = normalize(fixed3(p * .7,-1.5));
            fixed2x2 mx = mm2(time * .4 + um.x * 6.);
            fixed2x2 my = mm2(time * 0.3 + um.y * 6.);
            ro.xz = mul(ro.xz, mx);// *= mx;
            rd.xz = mul(rd.xz, mx);// *= mx;
            ro.xy = mul(ro.xy, my);// *= my;
            rd.xy = mul(rd.xy, my);// *= my;

            fixed3 bro = ro;
            fixed3 brd = rd;

            fixed3 col = fixed3(0.0125,0.,0.025);
            #if 1
            for (fixed j = 1.;j < NUM_RAYS + 1.;j++)
            {
                ro = bro;
                rd = brd;
                fixed2x2 mm = mm2((time * 0.1 + ((j + 1.) * 5.1)) * j * 0.25);
                ro.xy = mul(ro.xy, mm);
                rd.xy = mul(rd.xy, mm);
                ro.xz = mul(ro.xz, mm);
                rd.xz = mul(rd.xz, mm);
                fixed rz = march(ro,rd,2.5,FAR,j);
                if (rz >= FAR)continue;
                fixed3 pos = ro + rz * rd;
                col = max(col,vmarch(pos,rd,j, bro));
            }
            #endif

            ro = bro;
            rd = brd;
            fixed2 sph = iSphere2(ro, rd);

            if (sph.x > 0.)
            {
                fixed3 pos = ro + rd * sph.x;
                fixed3 pos2 = ro + rd * sph.y;
                fixed3 rf = reflect(rd, pos);
                fixed3 rf2 = reflect(rd, pos2);
                fixed nz = (-log(abs(flow(rf * 1.2, time) - .01)));
                fixed nz2 = (-log(abs(flow(rf2 * 1.2, -time) - .01)));
                col += (0.1 * nz * nz * fixed3(0.12, 0.12, .5) + 0.05 * nz2 * nz2 * fixed3(0.55, 0.2, .55)) * 0.8;
            }

            return fixed4(col * 1.3, 1.0);
        }

	    ENDCG
	    }
  }
}

