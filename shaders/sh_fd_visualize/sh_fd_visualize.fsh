varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	float a = texture2D(gm_BaseTexture, v_vTexcoord).a;
    gl_FragColor = vec4(vec3(1.), a);
}
