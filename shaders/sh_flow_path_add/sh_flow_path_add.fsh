varying vec4 v_vColour;

uniform vec2  direction;
uniform float flowTime;

void main() {
	float intensity = v_vColour.r;
	      intensity = smoothstep(0., 1., intensity);
	      intensity = intensity * intensity * intensity;
	
	gl_FragColor = vec4(direction * intensity, 0., 1.);
}