//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

vec4 sample ( vec2 position ) {
	if(position.x < 0.) return vec4(0.);
	if(position.y < 0.) return vec4(0.);
	if(position.x > 1.) return vec4(0.);
	if(position.y > 1.) return vec4(0.);
	
	return texture2D( gm_BaseTexture, position );
}

void main() {
	vec2 tx = 1. / dimension;
	
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	if(gl_FragColor.a == 0.) return;
	gl_FragColor = vec4(0.);
	
	bool l = sample( v_vTexcoord - vec2(tx.x, 0.) ).a == 0.;
	bool r = sample( v_vTexcoord + vec2(tx.x, 0.) ).a == 0.;
	bool u = sample( v_vTexcoord - vec2(0., tx.y) ).a == 0.;
	bool d = sample( v_vTexcoord + vec2(0., tx.y) ).a == 0.;
	
	if(l || r || u || d)
		gl_FragColor = v_vColour;
}
