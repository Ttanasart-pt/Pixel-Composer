//
// Simple passthrough fragment shader
//
varying float zDist;

void main() {
	float dist = 1. - (zDist - 1.) / 100.;
	gl_FragColor = vec4(vec3(dist), 1.);
}
