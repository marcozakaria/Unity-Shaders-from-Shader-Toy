// https://www.shadertoy.com/view/MsGczV
Shader "Custom/Gears Shader"
{

	Properties
    {
	    _Count("Gears Count",Range(2,20)) = 8
        _Speed("Speed",Range(0.0,2.0)) = 0.5
        _EPS("EPS  ",Range(0.0,20.0)) = 2.0
        _InnerTeeth("Inner teeth count",Range(1,64)) = 16
        _OuterTeeth("Outer teeth count",Range(1,128)) = 32
        _BaseColor("Base Color",Color) = (0.95, 0.7, 0.2)
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
	        //VertexInput
	    };


	    struct VertexOutput
        {
	        fixed4 pos : SV_POSITION;
	        fixed2 uv:TEXCOORD0;
	        //VertexOutput
	    };

	    //Variables
        fixed _Count;
        fixed _Speed;
        fixed _EPS;
        int _InnerTeeth;
        int _OuterTeeth;
        fixed4 _BaseColor;

        // Inspired by:
        //  http://cmdrkitten.tumblr.com/post/172173936860

        #define Pi 3.14159265359

        struct Gear
        {
            fixed t;			// Time
            fixed gearR;		// Gear radius
            fixed teethH;		// Teeth height
            fixed teethR;		// Teeth "roundness"
            fixed teethCount;	// Teeth count
            fixed diskR;		// Inner or outer border radius
            fixed3 color;			// Color
        };  
    
        fixed GearFunction(fixed2 uv, Gear g)
        {
            fixed r = length(uv);
            fixed a = atan2( uv.x,uv.y);
    
            // Gear polar function:
            //  A sine squashed by a logistic function gives a convincing
            //  gear shape!
            fixed p = g.gearR-0.5*g.teethH + 
                      g.teethH/(1.0+exp(g.teethR*sin(g.t + g.teethCount*a)));

            fixed gear = r - p;
            fixed disk = r - g.diskR;
    
            return g.gearR > g.diskR ? max(-disk, gear) : max(disk, -gear);
        }


        fixed GearDe(fixed2 uv, Gear g)
        {
            // IQ's f/|Grad(f)| distance estimator:
            fixed f = GearFunction(uv, g);
            fixed2 eps = fixed2(0.0001, 0);
            fixed2 grad = fixed2(
                GearFunction(uv + eps.xy, g) - GearFunction(uv - eps.xy, g),
                GearFunction(uv + eps.yx, g) - GearFunction(uv - eps.yx, g)) / (2.0*eps.x);
    
            return (f)/length(grad);
        }

        fixed GearShadow(fixed2 uv, Gear g)
        {
            fixed r = length(uv+fixed2(0.1,0.1));
            fixed de = r - g.diskR + 0.0*(g.diskR - g.gearR);
            fixed eps = 0.4*g.diskR;
            return smoothstep(eps, 0., abs(de));
        }

        void DrawGear(inout fixed3 color, fixed2 uv, Gear g, fixed eps)
        {
	        fixed d = smoothstep(eps, -eps, GearDe(uv, g));
            fixed s = 1.0 - 0.7*GearShadow(uv, g);
            color = lerp(s*color, g.color, d);
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
            fixed t = _Speed * _Time.y;
            fixed2 uv = 2.0 * (i.pos.xy - 0.5 * _ScreenParams.xy) / _ScreenParams.y;
            fixed eps = _EPS / _ScreenParams.y;

            // Scene parameters;
            fixed3 base = _BaseColor;
            fixed count =  max(2.0, _Count);

            Gear outer;
            outer.t = 0.0;
            outer.gearR = 0.8;
            outer.teethH = 0.08;
            outer.teethR = 4.0;
            outer.teethCount = _OuterTeeth;
            outer.diskR = 0.9;
            outer.color = base;

            Gear inner;
            inner.t = 0.0;
            inner.gearR = 0.4;
            inner.teethH = 0.08;
            inner.teethR = 4.0;
            inner.teethCount = _InnerTeeth;
            inner.diskR = 0.3;
            inner.color = base;
            //= Gear(0.0, 0.8, 0.08, 4.0, 32.0, 0.9, base);
            //Gear inner = Gear(0.0, 0.4, 0.08, 4.0, 16.0, 0.3, base);

            // Draw inner gears back to front:
            fixed3 color = fixed3(0.0,0.0,0.0);
            //[unroll(100)]

            for (fixed i = 0.0; i < count; i++)
            {
                t += 2.0 * Pi / count;
                inner.t = 16.0 * t;
                inner.color = base * (0.35 + 0.6 * i / (count - 1.0));
                DrawGear(color, uv + 0.4 * fixed2(cos(t),sin(t)), inner, eps);
               
            }

            // outer
            DrawGear(color, uv, outer, eps);
            return fixed4(color, 1.0);
        }
	ENDCG
	}
  }
}

