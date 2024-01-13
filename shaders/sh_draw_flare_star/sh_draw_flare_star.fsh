varying vec4 v_vColour;

float random (in vec2 st) { return fract(sin(dot(st.xy + vec2(21.456, 46.856), vec2(12.989, 78.233))) * 43758.545); }

void main() {
	float grey = (v_vColour.r + v_vColour.g + v_vColour.b) / 3. * v_vColour.a;
    gl_FragColor = vec4(vec3(1.), grey);
}
