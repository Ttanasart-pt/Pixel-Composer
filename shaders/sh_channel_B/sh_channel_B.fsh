//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord);
    gl_FragColor = vec4(0., 0., col.b, col.a);
}
