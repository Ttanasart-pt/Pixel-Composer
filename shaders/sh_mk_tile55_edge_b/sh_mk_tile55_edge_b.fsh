//////////////// 55 Tile Bottom ////////////////

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
	
	if(edge == 22 || edge == 16 || edge == 18) {
		if(fullEdge == 0 && tx.x < w - tx.y) discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.x < crop[2] ) discard;
		
	} else if(edge == 7 || edge == 24 || edge == 27 || edge == 30 || edge == 26 ) {
		
	} else if(edge == 11 || edge == 8 || edge == 10) {
		if(fullEdge == 0 && tx.x > tx.y)        discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.x > w - crop[0]) discard;
		
	} else if(edge == 2 || edge == 0) {
		if(fullEdge == 0 && tx.x < w - tx.y)    discard;
		if(fullEdge == 0 && tx.x > tx.y)        discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.x < crop[2] )    discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.x > w - crop[0]) discard;
		
	} else {
		bool draw = false;
		
		if(edge == 80 || edge == 120 || edge == 86 || edge == 127 || edge == 82 || edge == 123 || edge == 88 || edge == 95 || edge == 126 || edge == 122 || 
		   edge == 94 || edge == 91 || edge == 90) {
		   	
			if(fullEdge == 0 && tx.x + crop[2] >= tx.y + crop[1]) 
				draw = true;
				
			//if(fullEdge == 1 && (extendEdge == 1 || tx.x > w - crop[0])) 
			//	draw = true;
			if(fullEdge == 1)
				draw = true;
		} 
		
		if(edge == 216 || edge == 72 || edge == 223 || edge == 75 || edge == 222 || edge == 74 || edge == 88 || edge == 219 || edge == 95 || edge == 218 || 
		   edge == 94 || edge == 91 || edge == 90) {
		   	
			if(fullEdge == 0 && tx.x - crop[0] <= h - tx.y - crop[3]) 
				draw = true;
				
			//if(fullEdge == 1 && (extendEdge == 1 || tx.x < crop[2]))
			//	draw = true;
			if(fullEdge == 1)
				draw = true;
		}
		
		if(!draw) discard;
	}
	
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
}
