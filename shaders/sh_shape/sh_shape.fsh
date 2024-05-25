// 2D Signed Distance equations by InigoQuilez

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int shape;
uniform int bg;
uniform int aa;
uniform int sides;
uniform int tile;

uniform int  drawDF;
uniform vec2 dfLevel;

uniform float rotation;
uniform float angle;
uniform float inner;
uniform float outer;
uniform float corner;

uniform float stRad;
uniform float edRad;
uniform float parall;

uniform vec2 angle_range;

uniform vec2 dimension;
uniform vec2 center;
uniform vec2 scale;
uniform vec2 trep;

uniform vec4 bgColor;

#define PI  3.14159265359
#define TAU 6.283185307179586

float ndot(vec2 a, vec2 b ) { return a.x*b.x - a.y*b.y; }
float dot2(in vec2 v ) { return dot(v,v); }

float sdRegularPolygon(in vec2 p, in float r, in int n, in float ang ) {
    // these 4 lines can be precomputed for a given shape
    float an = PI / float(n);
    vec2  acs = vec2(cos(an), sin(an));

    // reduce to first sector
    float bn = mod(atan(p.x, p.y) + PI - ang, 2.0 * an) - an;
    p = length(p) * vec2(cos(bn), abs(sin(bn)));

    // line sdf
    p -= r * acs;
    p.y += clamp( -p.y, 0.0, r * acs.y);
    return length(p) * sign(p.x);
}

// signed distance to a n-star polygon with external angle en
float sdStar(in vec2 p, in float r, in int n, in float m, in float ang) { //m=[2,n]
    // these 4 lines can be precomputed for a given shape
    float an = PI / float(n);
    float en = PI / m;
    vec2  acs = vec2(cos(an), sin(an));
    vec2  ecs = vec2(cos(en), sin(en)); // ecs=vec2(0,1) and simplify, for regular polygon,

    // reduce to first sector
    float bn = mod( atan(p.x, p.y) + PI - ang, 2.0 * an) - an;
    p = length(p) * vec2(cos(bn), abs(sin(bn)));

    // line sdf
    p -= r * acs;
    p += ecs * clamp( -dot(p, ecs), 0.0, r * acs.y / ecs.y);
    return length(p)*sign(p.x);
} 

// sca is the sin/cos of the orientation
// scb is the sin/cos of the aperture
float sdArc( in vec2 p, in vec2 sca, in vec2 scb, in float ra, in float rb ) {
    p *= mat2(sca.x, sca.y, -sca.y, sca.x);
    p.x = abs(p.x);
    float k = (scb.y * p.x > scb.x * p.y) ? dot(p.xy,scb) : length(p);
    return sqrt( dot(p, p) + ra * ra - 2.0 * ra * k ) - rb;
}

float sdRoundBox( in vec2 p, in vec2 b, in vec4 r ) {
    r.xy = (p.x > 0.0)? r.xy : r.zw;
    r.x  = (p.y > 0.0)? r.x  : r.y;
    vec2 q = abs(p) - b + r.x;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r.x;
}

float sdBox( in vec2 p, in vec2 b ) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdTearDrop( vec2 p, float r1, float r2, float h ) {
    p.x = abs(p.x);
    float b = (r1 - r2) / h;
    float a = sqrt(1.0 - b * b);
    float k = dot(p, vec2(-b, a));
    if( k < 0.0 )   return length(p) - r1;
    if( k > a * h ) return length(p - vec2(0.0, h)) - r2;
    return dot(p, vec2(a, b) ) - r1;
}

float sdCross( in vec2 p, in vec2 b, float r ) {
    p = abs(p); 
    p = (p.y > p.x) ? p.yx : p.xy;
    vec2  q = p - b;
    float k = max(q.y, q.x);
    vec2  w = (k > 0.0) ? q : vec2(b.y - p.x, -k);
    return sign(k) * length(max(w, 0.0)) + r;
}

float sdVesica(vec2 p, float r, float d) {
    p = abs(p);

    float b = sqrt(r * r - d * d);  // can delay this sqrt by rewriting the comparison
    return ((p.y - b) * d > p.x * b) ? length(p - vec2(0.0, b)) * sign(d)
                                     : length(p - vec2(-d, 0.0)) - r;
}

float sdCrescent(vec2 p, float s, float c, float a) {
	float o = length(p) - 1.;
	float i = length(p - vec2(cos(a) * (1. - s * c), sin(a) * (1. - s * c))) / s - 1.;
	
	return max(o, -i);
}

float sdDonut(vec2 p, float s) {
	float o = length(p) - 1.;
	float i = length(p) / s - 1.;
	
	return max(o, -i);
}

float sdRhombus( in vec2 p, in vec2 b )  {
    p = abs(p);

    float h = clamp( ndot(b - 2.0 * p,b) / dot(b, b), -1.0, 1.0 );
    float d = length( p - 0.5 * b * vec2(1.0 - h, 1.0 + h) );

	return d * sign( p.x * b.y + p.y * b.x - b.x * b.y );
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b ) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa, ba) / dot(ba, ba), 0.0, 1.0 );
    return length( pa - ba * h );
}

float sdTrapezoid( in vec2 p, in float r1, float r2, float he ) {
    vec2 k1 = vec2(r2, he);
    vec2 k2 = vec2(r2 - r1, 2.0 * he);
    p.x = abs(p.x);
    
    vec2 ca = vec2(p.x - min(p.x, (p.y < 0.0)? r1 : r2), abs(p.y) - he);
    vec2 cb = p - k1 + k2 * clamp( dot(k1 - p, k2) / dot2(k2), 0.0, 1.0 );
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s * sqrt( min(dot2(ca), dot2(cb)) );
}

float sdParallelogram( in vec2 p, float wi, float he, float sk ) {
    vec2 e = vec2(sk, he);
    p = (p.y < 0.0)? -p : p;
    vec2  w = p - e; w.x -= clamp(w.x, -wi, wi);
    vec2  d = vec2(dot(w, w), -w.y);
    float s = p.x * e.y - p.y * e.x;
    p = (s < 0.0)? -p : p;
    vec2  v = p - vec2(wi, 0); v -= e * clamp(dot(v, e) / dot(e, e), -1.0, 1.0);
    d = min( d, vec2(dot(v, v), wi * he - abs(s)));
    return sqrt(d.x) * sign(-d.y);
}

void main() {
	float color = 0.;
	vec2  coord = (v_vTexcoord - center) * mat2(cos(rotation), -sin(rotation), sin(rotation), cos(rotation)) / scale;
	vec2  ratio = dimension / dimension.y;
	float d;
	
	if(tile == 1) coord = mod(coord + 1., 2.) - 1.;
	
	if(shape == 0) {
		d = sdBox( (v_vTexcoord - center) * mat2(cos(rotation), -sin(rotation), sin(rotation), cos(rotation)) * ratio, (scale * ratio - corner));
		d -= corner;
		
	} else if(shape == 1) {
		d = length(coord) - 1.;
		
	} else if(shape == 2) {
		d = sdRegularPolygon( coord, 0.9 - corner, sides, angle );
		d -= corner;
		
	} else if(shape == 3) {
	    d = sdStar( coord, 0.9 - corner, sides, 2. + inner * (float(sides) - 2.), angle );
		d -= corner;
		
	} else if(shape ==  4) d = sdArc(			coord, vec2(sin(angle), cos(angle)), angle_range, 0.9 - inner, inner );
	  else if(shape ==  5) d = sdTearDrop(		coord + vec2(0., 0.5), stRad, edRad, 1. );
	  else if(shape ==  6) d = sdCross( 		coord, vec2(1. + corner, outer), corner );
	  else if(shape ==  7) d = sdVesica(		coord, inner, outer );
	  else if(shape ==  8) d = sdCrescent(		coord, inner, outer, angle );
	  else if(shape ==  9) d = sdDonut( 		coord, inner );
	  else if(shape == 10) d = sdRhombus(		coord, vec2(1. - corner) ) - corner;
	  else if(shape == 11) d = sdTrapezoid( 	coord, trep.x - corner, trep.y - corner, 1. - corner ) - corner;
	  else if(shape == 12) d = sdParallelogram( coord, 1. - corner - parall, 1. - corner, parall) - corner;
	
	if(drawDF == 1) {
		color = -d;
		color = (color - dfLevel.x) / (dfLevel.y - dfLevel.x);
	} else if(aa == 0)
		color = step(d, 0.0);
	else
		color = smoothstep(0.02, -0.02, d);
	
	gl_FragColor = mix(bgColor, v_vColour, color);
}
