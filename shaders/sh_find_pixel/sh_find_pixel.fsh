//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D texture;
uniform vec2 dimension;

void main() {
	for(float i = 0.; i < dimension.y; i++)
	for(float j = 0.; j < dimension.x; j++) {
		vec4 col = texture2D( texture, vec2(j, i) / dimension );
		if(col == v_vColour) {
			gl_FragColor = vec4(j / dimension.x, i / dimension.y, 0., 1. );
			break;
		}
	}
}
