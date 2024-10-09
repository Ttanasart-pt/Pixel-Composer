// 2D Signed Distance equations by InigoQuilez

#ifdef _YY_HLSL11_ 
	#define CURVE_MAX 1024
#else 
	#define CURVE_MAX 512
#endif

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int shape;
uniform int bg;
uniform int aa;
uniform int sides;
uniform int tile;

uniform int   drawBG;
uniform int   drawDF;
uniform vec2  dfLevel;
uniform float w_curve[CURVE_MAX];
uniform int   w_amount;

uniform float rotation;
uniform float angle;
uniform float inner;
uniform float outer;
uniform float corner;

uniform float stRad;
uniform float edRad;
uniform float parall;

uniform vec2 angle_range;

uniform vec2  dimension;
uniform vec2  center;
uniform vec2  scale;
uniform vec2  trep;
uniform float shapeScale;
uniform int   endcap;

uniform int   teeth;
uniform vec2  teethSize;
uniform float teethAngle;
 
uniform float arrow;
uniform float arrow_head;
uniform float squircle_factor;

uniform vec2  point1;
uniform vec2  point2;
uniform float thickness;

uniform vec4 bgColor;

#define PI  3.14159265359
#define TAU 6.283185307179586

float ndot(vec2 a, vec2 b ) { return a.x*b.x - a.y*b.y; }
float dot2(in vec2 v ) { return dot(v,v); }

mat2 rot(in float ang) { return mat2(cos(ang), - sin(ang), sin(ang), cos(ang)); }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float eval_curve_segment_t(in float _y0, in float ax0, in float ay0, in float bx1, in float by1, in float _y1, in float prog) {
	return _y0 * pow(1. - prog, 3.) + 
		   ay0 * 3. * pow(1. - prog, 2.) * prog + 
		   by1 * 3. * (1. - prog) * pow(prog, 2.) + 
		   _y1 * pow(prog, 3.);
}

float eval_curve_segment_x(in float _y0, in float ax0, in float ay0, in float bx1, in float by1, in float _y1, in float _x) {
	float st = 0.;
	float ed = 1.;
	float _prec = 0.0001;
	
	float _xt = _x;
	int _binRep = 8;
	
	if(_x <= 0.) return _y0;
	if(_x >= 1.) return _y1;
	if(_y0 == ay0 && _y0 == by1 && _y0 == _y1) return _y0;
	
	for(int i = 0; i < _binRep; i++) {
		float _ftx = 3. * pow(1. - _xt, 2.) * _xt * ax0 
			       + 3. * (1. - _xt) * pow(_xt, 2.) * bx1
			       + pow(_xt, 3.);
		
		if(abs(_ftx - _x) < _prec)
			return eval_curve_segment_t(_y0, ax0, ay0, bx1, by1, _y1, _xt);
		
		if(_xt < _x) st = _xt;
		else		 ed = _xt;
		
		_xt = (st + ed) / 2.;
	}
	
	int _newRep = 16;
	
	for(int i = 0; i < _newRep; i++) {
		float slope = (  9. * ax0 - 9. * bx1 + 3.) * _xt * _xt
					+ (-12. * ax0 + 6. * bx1) * _xt
					+    3. * ax0;
		float _ftx = 3. * pow(1. - _xt, 2.) * _xt * ax0 
				   + 3. * (1. - _xt) * pow(_xt, 2.) * bx1
				   + pow(_xt, 3.)
				   - _x;
		
		_xt -= _ftx / slope;
		
		if(abs(_ftx) < _prec)
			break;
	}
	
	_xt = clamp(_xt, 0., 1.);
	return eval_curve_segment_t(_y0, ax0, ay0, bx1, by1, _y1, _xt);
}

float curveEval(in float[CURVE_MAX] curve, in int amo, in float _x) {
	
	int   _shf   = amo - int(floor(float(amo) / 6.) * 6.);
	int   _segs  = (amo - _shf) / 6 - 1;
	float _shift = _shf > 0? curve[0] : 0.;
	float _scale = _shf > 1? curve[1] : 1.;
	
	_x = _x / _scale - _shift;
	_x = clamp(_x, 0., 1.);
	
	for( int i = 0; i < _segs; i++ ) {
		int ind = _shf + i * 6;
		float _x0 = curve[ind + 2];
		float _y0 = curve[ind + 3];
	  //float bx0 = _x0 + curve[ind + 0];
	  //float by0 = _y0 + curve[ind + 1];
		float ax0 = _x0 + curve[ind + 4];
		float ay0 = _y0 + curve[ind + 5];
		
		float _x1 = curve[ind + 6 + 2];
		float _y1 = curve[ind + 6 + 3];
		float bx1 = _x1 + curve[ind + 6 + 0];
		float by1 = _y1 + curve[ind + 6 + 1];
	  //float ax1 = _x1 + curve[ind + 6 + 4];
	  //float ay1 = _y1 + curve[ind + 6 + 5];
		
		if(_x < _x0) continue;
		if(_x > _x1) continue;
		
		return eval_curve_segment_x(_y0, ax0, ay0, bx1, by1, _y1, (_x - _x0) / (_x1 - _x0));
	}
	
	return curve[0];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
	p = -p;
    p *= mat2(sca.x, sca.y, -sca.y, sca.x);
    p.x = abs(p.x);
    
    bool k = scb.y * p.x > scb.x * p.y;
    
    if(endcap == 1) return (k? length(p - scb * ra) : abs(length(p) - ra)) - rb;
	                return (k? 1. : abs(length(p) - ra)) - rb;
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b ) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa, ba) / dot(ba, ba), 0.0, 1.0 );
    return length( pa - ba * h );
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

float sdGear(vec2 p, float s, int teeth, vec2 teethSize, float teethAngle) {
	
	float teeth_w = teethSize.y;
	float teeth_h = teethSize.x;
	float s1;
	vec2  _p;
	
	float rad = 1. - teeth_w;
	float o = length(p) / rad- 1.;
	float i = length(p) / (rad * s) - 1.;
	float d = o;
	
	float _angSt  = TAU / float(teeth);
	for(int i = 0; i < teeth; i++) {
		_p = p;
		_p = _p * rot(radians(teethAngle) + float(i) * _angSt);
		_p = _p - vec2(1. - teeth_w, .0);
		
		s1 = sdBox(_p, vec2(teeth_w, teeth_h));
		d  = min(d, s1);
	}
	
	d = max(d, -i);
	
	return d;
}

float sdRhombus( in vec2 p, in vec2 b )  {
    p = abs(p);

    float h = clamp( ndot(b - 2.0 * p,b) / dot(b, b), -1.0, 1.0 );
    float d = length( p - 0.5 * b * vec2(1.0 - h, 1.0 + h) );

	return d * sign( p.x * b.y + p.y * b.x - b.x * b.y );
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

float sdHeart( in vec2 p ) {
    p.x = abs(p.x);
    p.y = -p.y + 0.9;
    p /= 1.65;
	
    if( p.y+p.x>1.0 )
        return sqrt(dot2(p-vec2(0.25,0.75))) - sqrt(2.0)/4.0;
    return sqrt(min(dot2(p-vec2(0.00,1.00)),
                    dot2(p-0.5*max(p.x+p.y,0.0)))) * sign(p.x-p.y);
}

float sdCutDisk( in vec2 p, in float r, in float h ) {
    float w = sqrt(r*r-h*h); // constant for any given shape
    p.x = abs(p.x);
    float s = max( (h-r)*p.x*p.x+w*w*(h+r-2.0*p.y), h*p.x-w*p.y );
    return (s<0.0) ? length(p)-r :
           (p.x<w) ? h - p.y     :
                     length(p-vec2(w,h));
}

float sdPie( in vec2 p, in vec2 c, in float r ) {
    p.x = abs(p.x);
    float l = length(p) - r;
    float m = length(p-c*clamp(dot(p,c),0.0,r)); // c=sin/cos of aperture
    return max(l,m*sign(c.y*p.x-c.x*p.y));
}

float sdRoundedCross( in vec2 p, in float h ) {
    float k = 0.5*(h+1.0/h);               // k should be const/precomputed at modeling time
    
    p = abs(p);
    return ( p.x<1.0 && p.y<p.x*(k-h)+h ) ? 
             k-sqrt(dot2(p-vec2(1,k)))  :  // circular arc
           sqrt(min(dot2(p-vec2(0,h)),     // top corner
                    dot2(p-vec2(1,0))));   // right corner
}

float sdArrow( in vec2 p, vec2 a, vec2 b, float w1, float w2, float k ) { // The arrow goes from a to b. It's thickness is w1. The arrow head's thickness is w2.
    // constant setup
    
	vec2  ba = b - a;
    float l2 = dot(ba,ba);
    float l  = sqrt(l2);

    // pixel setup
    p = p - a;
    p = mat2(ba.x, -ba.y, ba.y, ba.x) * p / l;
    p.y = abs(p.y);
    vec2 pz = p - vec2(l - w2 * k, w2);
	
    // === distance (four segments) === 
	
    vec2 q = p;
    q.x -= clamp( q.x, 0.0, l - w2 * k );
    q.y -= w1;
    float di = dot(q,q);
    //----
    q = pz;
    q.y -= clamp( q.y, w1 - w2, 0.0 );
    di = min( di, dot(q, q) );
    //----
    if( p.x < w1 ) { // conditional is optional
	    q = p;
	    q.y -= clamp( q.y, 0.0, w1 );
	    di = min( di, dot(q, q) );
    }
    //----
    if( pz.x > 0.0 ) { // conditional is optional
	    q = pz;
	    q -= vec2(k, -1.0) * clamp( (q.x * k - q.y) / (k * k + 1.0), 0.0, w2 );
	    di = min( di, dot(q, q) );
    }
    
    // === sign === 
    
    float si = 1.0;
    float z = l - p.x;
    if( min(p.x, z) > 0.0 ) { //if( p.x>0.0 && z>0.0 )
		float h = (pz.x < 0.0) ? w1 : z / k;
		if( p.y < h ) si = -1.0;
    }
    
    return si * sqrt(di);
}

float sdHalf(vec2 p, vec2 point, float angle) {
    p -= point;
    p = mat2(cos(angle), -sin(angle), sin(angle), cos(angle)) * p;
    return -p.y;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void main() {
	vec2  coord = (v_vTexcoord - center) * mat2(cos(rotation), -sin(rotation), sin(rotation), cos(rotation)) / scale;
	vec2  ratio = dimension / dimension.y;
	float d;
	
	vec2 p1 = point1 / dimension;
	vec2 p2 = point2 / dimension;
	
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
		
	} 
	else if(shape ==  4) { d = sdArc(           coord, vec2(sin(angle), cos(angle)), angle_range, 1. - inner, inner );	                                  }
	else if(shape ==  5) { d = sdTearDrop(      coord + vec2(0., 0.5), stRad, edRad, 1. );                      		                                  }
	else if(shape ==  6) { d = sdCross(         coord, vec2(1. + corner, outer), corner );                          	                                  }
	else if(shape ==  7) { d = sdVesica(        coord, inner, outer );                                              	                                  }
	else if(shape ==  8) { d = sdCrescent(      coord, inner, outer, angle );                                   		                                  }
	else if(shape ==  9) { d = sdDonut(         coord, inner );                                                     	                                  }
	else if(shape == 10) { d = sdRhombus(       coord, vec2(1. - corner) ) - corner;                                	                                  }
	else if(shape == 11) { d = sdTrapezoid(     coord, trep.x - corner, trep.y - corner, 1. - corner ) - corner;		                                  }
	else if(shape == 12) { d = sdParallelogram(	coord, 1. - corner - parall, 1. - corner, parall) - corner;   			                                  }
	else if(shape == 13) { d = sdHeart(         coord );                                                            	                                  }
	else if(shape == 14) { d = sdCutDisk( 		coord, 1., inner );                                             		                                  }
	else if(shape == 15) { d = sdPie( 			coord, vec2(sin(angle), cos(angle)), 1. );                          	                                  }
	else if(shape == 16) { d = sdRoundedCross( 	coord, 1. - corner ) - corner;                              			                                  }
	else if(shape == 18) { d = sdGear(          coord, inner, teeth, teethSize, teethAngle);                        	                                  }
	else if(shape == 19) { d = pow(pow(abs(coord.x), squircle_factor) + pow(abs(coord.y), squircle_factor), 1. / squircle_factor) - 1.;                   }
	else if(shape == 17) { d = sdArrow(  v_vTexcoord, p1, p2, thickness, arrow, arrow_head);                               	                              }
	else if(shape == 20) { d = sdSegment(v_vTexcoord, p1, p2) - thickness;                                                                                }
	else if(shape == 21) { d = sdHalf(v_vTexcoord, p1, -rotation);                                                                                        }
	
	float cc, color = 0.;
	
	if(aa == 0) 
		cc = step(d, 0.0);
	else {
		float _aa = 1. / max(dimension.x, dimension.y);
		cc = smoothstep(_aa, -_aa, d);
	}
	
	color = cc;
	if(drawDF == 1) {
		color  = -d;
		color  = clamp((color - dfLevel.x) / (dfLevel.y - dfLevel.x), 0., 1.);
		color  = curveEval(w_curve, w_amount, color);
		
		color *= cc;
	}
	
	if(drawBG == 0) gl_FragColor = vec4(v_vColour.rgb, v_vColour.a * color);
	else            gl_FragColor = mix(bgColor, v_vColour, color);
}
