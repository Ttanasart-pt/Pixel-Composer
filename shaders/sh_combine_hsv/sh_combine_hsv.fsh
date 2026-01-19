varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int space;

uniform sampler2D samH;
uniform sampler2D samS;
uniform sampler2D samV;
uniform sampler2D samA;

uniform int useH;
uniform int useS;
uniform int useV;
uniform int useA;

float hue2rgb( in float m1, in float m2, in float hue) {
	if (hue < 0.0)
		hue += 1.0;
	else if (hue > 1.0)
		hue -= 1.0;

	if ((6.0 * hue) < 1.0)
		return m1 + (m2 - m1) * hue * 6.0;
	else if ((2.0 * hue) < 1.0)
		return m2;
	else if ((3.0 * hue) < 2.0)
		return m1 + (m2 - m1) * ((2.0 / 3.0) - hue) * 6.0;
	else
		return m1;
}

vec3 hsl2rgb( in vec3 hsl ) {
	float r, g, b;
	if(hsl.y == 0.) {
		r = hsl.z;
		g = hsl.z;
		b = hsl.z;
		
	} else {
		float m1, m2;
		if(hsl.z <= 0.5)
			m2 = hsl.z * (1. + hsl.y);
		else 
			m2 = hsl.z + hsl.y - hsl.z * hsl.y;
		m1 = 2. * hsl.z - m2;
		
		r = hue2rgb(m1, m2, hsl.x + 1. / 3.);
		g = hue2rgb(m1, m2, hsl.x);
		b = hue2rgb(m1, m2, hsl.x - 1. / 3.);
	}
	
	return vec3( r, g, b );
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float sample(vec4 col, int ch) { return (col[0] + col[1] + col[2]) / 3. * col[3]; }

void main() {
	float h = (useH == 1)? sample(texture2D( samH, v_vTexcoord ), 0) : 0.;
	float s = (useS == 1)? sample(texture2D( samS, v_vTexcoord ), 1) : 0.;
	float v = (useV == 1)? sample(texture2D( samV, v_vTexcoord ), 2) : 0.;
	float a = (useA == 1)? sample(texture2D( samA, v_vTexcoord ), 3) : 1.;
	
	gl_FragColor = space == 1? vec4(hsl2rgb(vec3(h, s, v)), a) : vec4(hsv2rgb(vec3(h, s, v)), a);
}
