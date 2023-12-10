//////////////// 55 Tile Left ////////////////

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec4 crop;
uniform int edge;
uniform int fullEdge;
uniform int extendEdge;

void main() {
	float  w = dimension.x;
	float  h = dimension.y;
	
	vec2  tx = v_vTexcoord * dimension;
	gl_FragColor = vec4(0.);
	
	if(edge == 208 || edge == 64 || edge == 80) {
		if(fullEdge == 0 && tx.x > tx.y)    discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y < crop[1]) discard;
		
	} else if(edge == 148 || edge == 66 || edge == 86 || edge == 210 || edge == 82) {
		
	} else if(edge == 22 || edge == 2 || edge == 18) {
		if(fullEdge == 0 && tx.x > h - tx.y)    discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y > h - crop[3]) discard;
		
	} else if(edge == 16 || edge == 0) {
		if(fullEdge == 0 && tx.x > tx.y)        discard;
		if(fullEdge == 0 && tx.x > h - tx.y)    discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y < crop[1])     discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y > h - crop[3]) discard;
		
	} else {
		bool draw = false;
		
		if(edge == 216 || edge == 72 || edge == 223 || edge == 75 || edge == 222 || edge == 74 || edge == 95 || edge == 88 || edge == 219 || edge == 218 || edge == 94 || edge == 91 || edge == 90) {
			if(fullEdge == 0 && tx.x - crop[0] >= h - tx.y - crop[3]) 
				draw = true;
				
			//if(fullEdge == 1 && (extendEdge == 1 || tx.y > h - crop[3]))
			//	draw = true;
			if(fullEdge == 1)
				draw = true;
		} 
		
		if(edge == 254 || edge == 106 || edge == 30 || edge == 10 || edge == 222 || edge == 74 || edge == 126 || edge == 250 || edge == 218 || edge == 122 || edge == 26 || edge == 94 || edge == 90) {
			if(fullEdge == 0 && tx.x - crop[0] > tx.y - crop[3]) 
				draw = true;
				
			//if(fullEdge == 1 && (extendEdge == 1 || tx.y < crop[1]))
			//	draw = true;
			if(fullEdge == 1)
				draw = true;
		}
		
		if(!draw) discard;
	}
	
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
}
