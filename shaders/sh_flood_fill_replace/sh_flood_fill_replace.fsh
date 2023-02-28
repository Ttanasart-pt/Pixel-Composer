//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 color;
uniform sampler2D mask;

void main() {
    vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
    vec4 msk = texture2D( mask, v_vTexcoord );
	
	gl_FragColor = msk.rgb == vec3(1., 0., 0.)? color : col;
}
