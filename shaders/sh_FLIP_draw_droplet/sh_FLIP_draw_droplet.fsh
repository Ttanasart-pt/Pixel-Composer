varying vec4 v_vColour;

void main() {
	float a = v_vColour.a;
	      a = pow(a, 5.);
	
    gl_FragColor = vec4(v_vColour.rgb, a);
}
