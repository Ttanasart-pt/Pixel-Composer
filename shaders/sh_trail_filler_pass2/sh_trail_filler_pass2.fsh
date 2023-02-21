//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
    vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	float u = 0.;
	float v = col.b;
	
	if(col.a < 0.5) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	float pos = 0.;
	vec2 scPos = v_vTexcoord;
	for( float i = 0.; i < dimension.x; i++ ) {
		vec4 sm = texture2D( gm_BaseTexture, scPos );
		if(sm.a < 0.5) break;
		
		scPos.x -= sm.y;
		scPos.y += sm.x;
		pos++;
	}
	
	float tot = 0.;
	vec2 scTot = v_vTexcoord;
	for( float i = 0.; i < dimension.x; i++ ) {
		vec4 sm = texture2D( gm_BaseTexture, scTot );
		if(sm.a < 0.5) break;
		
		scTot.x += sm.y;
		scTot.y -= sm.x;
		tot++;
	}
	
	u = pos / (pos + tot);
	gl_FragColor = vec4(u, v, 0., col.a);
}
