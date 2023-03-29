//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D replace;
uniform vec2 replace_dim;
uniform sampler2D findRes;

void main() {
    vec4 res = texture2D( findRes, v_vTexcoord );
	if(res.a == 1.)
		gl_FragColor = texture2D( replace, res.rg );
	else 
		gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
}
