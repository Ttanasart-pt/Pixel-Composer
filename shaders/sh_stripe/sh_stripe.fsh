//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int gradient_use;
uniform int gradient_blend;
uniform vec4 gradient_color[16];
uniform float gradient_time[16];
uniform int gradient_keys;

uniform vec2 dimension;
uniform vec2 position;
uniform float angle;
uniform float amount;
uniform float rand;
uniform int blend;

float random (in vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec4 gradientEval(in float prog) {
	vec4 col = vec4(0.);
	
	for(int i = 0; i < 16; i++) {
		if(gradient_time[i] == prog) {
			col = gradient_color[i];
			break;
		} else if(gradient_time[i] > prog) {
			if(i == 0) 
				col = gradient_color[i];
			else {
				if(gradient_blend == 0)
					col = mix(gradient_color[i - 1], gradient_color[i], (prog - gradient_time[i - 1]) / (gradient_time[i] - gradient_time[i - 1]));
				else if(gradient_blend == 1)
					col = gradient_color[i - 1];
			}
			break;
		}
		if(i >= gradient_keys - 1) {
			col = gradient_color[gradient_keys - 1];
			break;
		}
	}
	
	return col;
}

void main() {
	vec2 pos = v_vTexcoord - position;
	float ratio = dimension.x / dimension.y;
	float prog = pos.x * ratio * cos(angle) - pos.y * sin(angle);
    float _a   = 1. / amount;
	
	float slot = floor(prog / _a);
	float ground  = (slot + (random(vec2(slot + 0.)) * 2. - 1.) * rand * 0.5 + 0.) * _a;
	float ceiling = (slot + (random(vec2(slot + 1.)) * 2. - 1.) * rand * 0.5 + 1.) * _a;
	float _s   = (prog - ground) / (ceiling - ground);
	
	if(gradient_use == 0) {
		if(blend == 0) {
			if(_s > .5)
				gl_FragColor = vec4(vec3(0.), 1.);
			else
				gl_FragColor = vec4(vec3(1.), 1.);
		} else
			gl_FragColor = vec4(vec3(abs(_s - 0.5) * 2.), 1.);
	} else {
		if(_s > .5)
			gl_FragColor = vec4(gradientEval(random(vec2(slot))).rgb, 1.);
		else
			gl_FragColor = vec4(gradientEval(random(vec2(slot + 1.))).rgb, 1.);
	}
}
