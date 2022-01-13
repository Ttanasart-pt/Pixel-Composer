//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D mask;

void main() {
	vec4 m = texture2D( mask, v_vTexcoord );
	if(length(m.rgb * m.a) > 0.1)
		gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	else	
		gl_FragColor = vec4(0.);
}
