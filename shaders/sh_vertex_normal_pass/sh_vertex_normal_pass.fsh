//
// Simple passthrough fragment shader
//
varying vec3 v_vNormal;

void main() {
	gl_FragColor = vec4((v_vNormal + 1.) / 2., 1.);
}
