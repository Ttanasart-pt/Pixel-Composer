//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  u_resolution;
uniform vec2  position;
uniform float rotation;
uniform vec2  scale;
uniform int   iteration;
uniform float bright;

float random (in vec2 st) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123); }

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

	float _my = abs(i.y - (floor(i.y / 2.) * 2.));
    
	float a, b, c;
	
	if(_my < 1.) {
		if(f.x > f.y) {
		    a = random(i);
		    b = random(i + vec2(1.0, 0.0));
		    c = random(i + vec2(1.0, 1.0));
		} else {
			a = random(i);
		    b = random(i + vec2(0.0, 1.0));
		    c = random(i + vec2(1.0, 1.0));
		}
	} else {
		if(1. - f.x < f.y) {
		    a = random(i);
		    b = random(i + vec2(1.0, 0.0));
		    c = random(i + vec2(1.0, 1.0));
		} else {
			a = random(i);
		    b = random(i + vec2(0.0, 1.0));
		    c = random(i + vec2(1.0, 1.0));
		}
	}

	vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), c, u.y);
}

void main() {
	float ang = radians(rotation);
	vec2 pos  = position / u_resolution;
	vec2 st   = (v_vTexcoord - pos) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * scale;
	
	float amp = bright;
    float n = 0.;
	
	for(int i = 0; i < iteration; i++) {
		n += noise(st) * amp;
		
		amp *= .5;
		pos *= 2.;
	}
	

    gl_FragColor = vec4(vec3(n), 1.0);
}
