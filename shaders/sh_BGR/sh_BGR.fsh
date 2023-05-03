//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 clr = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = clr.bgra;
}
