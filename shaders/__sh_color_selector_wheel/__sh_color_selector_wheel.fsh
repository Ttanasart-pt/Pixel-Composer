varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  size;
uniform float hue;
uniform float hover;

#define PI 3.14159265358979323846

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 hsl2rgb(vec3 c) {
	float H = c.x * 360.;

	float C = (1. - abs(2. * c.z - 1.)) * c.y;
	float X = C * (1. - abs(mod(H / 60., 2.) - 1.));
	float m = c.z - C / 2.;

	vec3 rgb = vec3(0.);

	     if(H <  60.) rgb = vec3(C, X, 0.);
	else if(H < 120.) rgb = vec3(X, C, 0.);
	else if(H < 180.) rgb = vec3(0., C, X);
	else if(H < 240.) rgb = vec3(0., X, C);
	else if(H < 300.) rgb = vec3(X, 0., C);
	else              rgb = vec3(C, 0., X);

	rgb += vec3(m);
	return rgb;
}

float sdRegularPolygon(in vec2 p, in float r, in int n, in float ang ) {
    // these 4 lines can be precomputed for a given shape
    float an  = PI / float(n);
    vec2  acs = vec2(cos(an), sin(an));

    // reduce to first sector
    float bn = mod(atan(p.x, p.y) + PI - ang, 2.0 * an) - an;
    p = length(p) * vec2(cos(bn), abs(sin(bn)));
	
    // line sdf
    p -= r * acs;
    p.y += clamp( -p.y, 0.0, r * acs.y);
    return length(p) * sign(p.x);
}

void main() {
	vec2  tx  = v_vTexcoord - .5;
	float c   = length(tx) * 2.;
	float a   = 0.;
	vec3  clr = vec3(1.);
	
	if(c > .8 && c < 1.) { // ring
		float ang = atan(tx.y, -tx.x);
		ang = ang / PI / 2. + .5;
		clr = hsv2rgb(vec3(ang, 1., 1.));
		
		a = 1.;
		if(hover == 0. || hover == 1.) a = 1.;
	}
	
	if(c < .8) { // triangle
		float tri = sdRegularPolygon(tx, .4, 3, -PI / 2. + hue * PI * 2.);
		
		if(tri < 0.) {
			clr = vec3(1.);
			
			a = 1.;
			if(hover == 0. || hover == 2.) a = 1.;
		
			float ang = hue * PI * 2.;
			vec2  txx = tx * mat2(cos(ang), -sin(ang), sin(ang), cos(ang));

			float slen = .4 * sin(PI / 6.);
			float sat  = (txx.x + slen) / (.4 + slen);
			
			float lum  = 1. - (txx.y + .4) / .8;
			vec3  hsl  = vec3(hue, sat, lum);

			clr = hsl2rgb(hsl);
		}
	}
	
	gl_FragColor.rgb = clr;
	gl_FragColor.a   = a;
}