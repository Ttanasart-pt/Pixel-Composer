//////////////// 55 Tile Bottom ////////////////

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
	
	if(edge == 22 || edge == 16 || edge == 18) {
		if(tx.x < w - tx.y) discard;
		
	} else if(edge == 7 || edge == 24 || edge == 27 || edge == 30 || edge == 26 ) {
		
	} else if(edge == 11 || edge == 8 || edge == 10) {
		if(tx.x > tx.y) discard;
		
	} else if(edge == 2 || edge == 0) {
		if(tx.x < w - tx.y) discard;
		if(tx.x > tx.y)     discard;
		
	} else {
		bool draw = false;
		
		if(edge == 80 || edge == 120 || edge == 86 || edge == 127 || edge == 82 || edge == 123 || edge == 88 || edge == 95 || edge == 126 || edge == 122 || edge == 94 || edge == 91 || edge == 90) {
			if(tx.x + crop[2] >= tx.y + crop[1]) 
				draw = true;
		} 
		
		if(edge == 216 || edge == 72 || edge == 223 || edge == 75 || edge == 222 || edge == 74 || edge == 88 || edge == 219 || edge == 95 || edge == 218 || edge == 94 || edge == 91 || edge == 90) {
			if(tx.x - crop[0] < h - tx.y - crop[3]) 
				draw = true;
		}
		
		if(!draw) discard;
	}
	
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
}
