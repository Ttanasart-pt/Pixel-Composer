//
// Simple passthrough fragment shader
//
//varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	float g = v_vColour.g;
	      g = g * g;
	
    gl_FragColor = vec4(vec3(g), 1.);
}
