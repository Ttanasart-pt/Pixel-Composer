//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec4 crop;
uniform int edge;

void main() {
	float  w = dimension.x;
	float  h = dimension.y;
	
	vec2  tx = v_vTexcoord * dimension;
	gl_FragColor = vec4(0.);
	
	if(edge == 8) {
		if(tx.x < tx.y) discard;
		
	} else if(edge == 12) {
		
	} else if(edge == 4) {
		if(tx.x > h - tx.y) discard;
		
	} else if(edge == 13) {
		if(tx.x - crop[2] < h - tx.y - crop[3]) discard;
		
	} else if(edge == 14) {
		if(tx.x + crop[0] > tx.y + crop[1]) discard;
		
	} else if(edge ==  9) {
		if(tx.x - crop[2] < tx.y - crop[1]) discard;
		
	} else if(edge ==  6) {
		if(tx.x + crop[0] > h - tx.y + crop[3]) discard;
		
	} else {
		discard;
	}
	
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
}
