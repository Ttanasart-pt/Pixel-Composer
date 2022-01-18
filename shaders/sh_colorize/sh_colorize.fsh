//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int gradient_blend;
uniform vec4 gradient_color[16];
uniform float gradient_time[16];
uniform int keys;
uniform float gradient_shift;

void main() {
	vec4 _col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	float prog = fract(dot(_col.rgb, vec3(0.2126, 0.7152, 0.0722)) + gradient_shift);
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
		if(i >= keys - 1) {
			col = gradient_color[keys - 1];
			break;
		}
	}
	col.a = _col.a;
	
    gl_FragColor = col;
}
