//////////////// 55 Tile Top ////////////////

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
	
	if(edge == 208 || edge == 16 || edge == 80) {
		if(tx.x < tx.y) discard;
		
	} else if(edge == 224 || edge == 24 || edge == 120 || edge == 216 || edge == 88) {
		
	} else if(edge == 104 || edge == 8 || edge == 72) {
		if(tx.x > h - tx.y) discard;
	
	} else if(edge == 64 || edge == 0) {
		if(tx.x < tx.y)     discard;
		if(tx.x > h - tx.y) discard;
		
	} else {
		bool draw = false;
		
		if(edge == 210 || edge == 251 || edge == 18 || edge == 27 || edge == 82 || edge == 123 || edge == 219 || edge == 250 || edge == 218 || edge == 122 || edge == 26 || edge == 91 || edge == 90) {
			if(tx.x - crop[2] >= h - tx.y - crop[3]) 
				draw = true;
		} 
	
		if(edge == 254 || edge == 106 || edge == 30 || edge == 10 || edge == 222 || edge == 74 || edge == 126 || edge == 250 || edge == 218 || edge == 122 || edge == 26 || edge == 94 || edge == 90) {
			if(tx.x + crop[0] <= tx.y + crop[1]) 
				draw = true;
		} 
		
		if(!draw) discard;
	}
	
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
}
