//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int keepAlpha;

void main() {
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord);
    gl_FragColor = vec4(col.g, col.g, col.g, keepAlpha == 1? col.a : 1.);
}
