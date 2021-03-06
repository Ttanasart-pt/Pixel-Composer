//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU   6.28318

uniform int gradient_blend;
uniform vec4 gradient_color[16];
uniform float gradient_time[16];
uniform int gradient_keys;
uniform int gradient_loop;

uniform vec2 center;
uniform float angle;
uniform float radius;
uniform float shift;
uniform int type;

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
	float prog = 0.;
	if(type == 0) {
		prog = .5 + (v_vTexcoord.x - center.x) * cos(angle) - (v_vTexcoord.y - center.y) * sin(angle);
	} else if(type == 1) {
		prog = distance(v_vTexcoord, center) / radius;
	} else if(type == 2) {
		vec2  _p = v_vTexcoord - center;
		float _a = atan(_p.y, _p.x) + angle;
		prog = (_a - floor(_a / TAU) * TAU) / TAU;
	}
	prog = prog + shift;
	if(gradient_loop == 1) { 
		prog = abs(prog);
		if(prog > 1.) {
			if(prog == floor(prog))
				prog = 1.;
			else 
				prog = fract(prog);
		}
	}
	
	vec4 col = gradientEval(prog);
	
    gl_FragColor = col;
}
