varying vec4 v_vColour;

void main() {
	gl_FragColor = v_vColour;
	gl_FragColor.rgb /= gl_FragColor.a;
}
