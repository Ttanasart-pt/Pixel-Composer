varying vec4 v_vColour;

uniform vec2 smooth;

void main() {
	float grey = (v_vColour.r + v_vColour.g + v_vColour.b) / 3. * v_vColour.a;
	grey = smoothstep(smooth.x, smooth.y, grey);
	
    gl_FragColor = vec4(vec3(1.), grey);
}
