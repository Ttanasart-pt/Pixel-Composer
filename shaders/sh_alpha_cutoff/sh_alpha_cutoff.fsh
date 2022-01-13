//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float cutoff;

void main() {
    vec4 col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	if(col.a >= cutoff)
		gl_FragColor = col;
	else
		gl_FragColor = vec4(0.);
}
