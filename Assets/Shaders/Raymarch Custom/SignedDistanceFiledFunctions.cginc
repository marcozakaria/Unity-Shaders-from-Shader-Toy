// SDF functions
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

float GetDistRoundBox( float3 p, float3 b, float r )
{
 	float3 q = abs(p) - b;
 	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float GetDistCone(float3 p, float3 c )
{
  // c is the sin/cos of the angle
  float q = length(p.xy);
  return dot(c,float2(q,p.z));
}

float GetDistTorus(float3 p,float r1, float r2)
{
	float d = length( float2( length(p.xz) - r1 , p.y)) - r2; // torus
	return d; 
}

// blend two objects to gether with softness value k 
float SmoothMinimum(float distA, float distB, float k)
{
	float h = clamp(0.5 + 0.5*(distB-distA)/k, 0.0 , 1.0);
	return (lerp(distB, distA, h) - k*h*(1.0-h));
}

float GetDistPlane(float3 p , float3 rot)
{
	return dot(p, normalize(rot));
}

float GetDistOctahedron(float3 p, float s)
{
	p = abs(p);
	return (p.x+p.y+p.z-s)*0.57735027;
}

// BOOLEAN OPERATORS //

// when object go inside object and we cut the part of B from A ,Subtraction
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

// Mod Position Axis , repeat shape to infinite without any performanve cose
float PMod1(inout float p, float size)
{
	float halfsize = size * 0.5;
	float c = floor((p+halfsize)/size);
	p = fmod(p+halfsize,size)-halfsize;
	p = fmod(-p+halfsize,size)-halfsize;
	return c;
}