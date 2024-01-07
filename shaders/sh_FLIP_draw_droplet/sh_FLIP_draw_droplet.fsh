//
// Simple passthrough fragment shader
//
//varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	float g = v_vColour.g;
	      g = pow(g, 5.);
	
    gl_FragColor = vec4(vec3(g), v_vColour.a);
}
