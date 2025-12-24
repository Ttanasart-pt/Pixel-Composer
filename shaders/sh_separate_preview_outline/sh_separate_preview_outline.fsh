varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float threshold;

bool masked(vec4 col) {
	float v = (col.r + col.g + col.b) / 3. * col.a;
	return v < threshold;
}

void main() {
	gl_FragColor = vec4(0.);
	
	vec2 tx = 1. / dimension;
	bool bb = masked( texture2D(gm_BaseTexture, v_vTexcoord)                  );
	bool b0 = masked( texture2D(gm_BaseTexture, v_vTexcoord + vec2(tx.x, 0.)) );
	bool b1 = masked( texture2D(gm_BaseTexture, v_vTexcoord - vec2(tx.x, 0.)) );
	bool b2 = masked( texture2D(gm_BaseTexture, v_vTexcoord + vec2(0., tx.y)) );
	bool b3 = masked( texture2D(gm_BaseTexture, v_vTexcoord - vec2(0., tx.y)) );
	
	if(!bb &&  (b0 || b1 || b2 || b3))
		gl_FragColor = v_vColour;
	
	if( bb && !(b0 || b1 || b2 || b3))
		gl_FragColor = v_vColour;
		
}