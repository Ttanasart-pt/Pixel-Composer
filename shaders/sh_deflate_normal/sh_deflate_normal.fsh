varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float radius;
uniform float amount;
uniform float factor;
uniform float offset;
uniform float resolution;

#define s2 1.4142135623731
#define PI 3.14159265358979323846

void main() {
	vec2 tx = 1. / dimension;
	
    float c   = texture2D(gm_BaseTexture, v_vTexcoord).r;
    float crv = 0.;
    
    float ast = max(1., ceil(radius) / 4.);
    float ang = PI / resolution;
    
    for(float i = 1.; i <= ceil(radius); i++)
    for(float a = 0.; a < resolution; a++) {
    	
    	float _i = min(i, radius);
		float aa = ang * a;
    	vec2  o  = tx * _i * mat2(cos(aa), -sin(aa), sin(aa), cos(aa));
    	
	    float l  = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-o.x,  0.0)).r;
	    float r  = texture2D(gm_BaseTexture, v_vTexcoord + vec2( o.x,  0.0)).r;
	    float t  = texture2D(gm_BaseTexture, v_vTexcoord + vec2( 0.0,  o.y)).r;
	    float b  = texture2D(gm_BaseTexture, v_vTexcoord + vec2( 0.0, -o.y)).r;
	    
	    float tl = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-o.x,  o.y) * s2).r;
	    float tr = texture2D(gm_BaseTexture, v_vTexcoord + vec2( o.x,  o.y) * s2).r;
	    float bl = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-o.x, -o.y) * s2).r;
	    float br = texture2D(gm_BaseTexture, v_vTexcoord + vec2( o.x, -o.y) * s2).r;
	    
	    float dxx = (r - 2. * c + l) / (radius * radius);
	    float dyy = (t - 2. * c + b) / (radius * radius);
	    
	    float d1 = (tr - 2. * c + bl) / (radius * radius * 2.);
	    float d2 = (tl - 2. * c + br) / (radius * radius * 2.);
	    
	    float curv = (dxx + dyy + d1 + d2) * .5;
	    float intn = 1. - i / radius;
	    
	    crv += curv * intn;
    }
    
    float grey = .5 - .5 * crv * amount * 10.;
	gl_FragColor = vec4(grey, 1., 0., 1.);
}

// void main() {
// 	vec2 tx = 1. / dimension;
	
// 	float r00 = texture2D(gm_BaseTexture, v_vTexcoord).r;
	
// 	vec2  dd = vec2(0.);
// 	float ww = 0.;
// 	float wt = 0.;
	
// 	for(float x = -radius; x <= radius; x++) 
// 	for(float y = -radius; y <= radius; y++) {
// 		if(x == 0. && y == 0.) continue;
		
// 		vec2  sx = v_vTexcoord + vec2(x, y) * tx;
// 		float rr = texture2D(gm_BaseTexture, sx).r;
		
// 		dd += (rr - r00) * normalize(vec2(x, y));
// 		ww += (rr - r00);
// 		wt++;
// 	}
	
// 	float w = 1. - abs(ww / wt) * 2. + offset;
// 	      w = pow(w, 1. + factor);
	
// 	float ang = atan(dd.y, dd.x);
// 	gl_FragColor = vec4(ang, w, 0., 1.);
// }