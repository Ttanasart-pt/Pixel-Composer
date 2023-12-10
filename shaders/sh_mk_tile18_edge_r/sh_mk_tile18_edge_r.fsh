//////////////// 18 Tile Right ////////////////

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
	
	if(edge == 4) {
		if(fullEdge == 0 && tx.x < h - tx.y) discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y < crop[1])  discard;
		
	} else if(edge == 5) {
		
	} else if(edge == 1) {
		if(fullEdge == 0 && tx.x < tx.y) discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y > h - crop[3]) discard;
		
	} else if(edge == 7) {
		if(fullEdge == 0 && tx.x + crop[0] > tx.y + crop[3])   discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y < crop[1]) discard;
		
	} else if(edge == 13) {
		if(fullEdge == 0 && tx.x + crop[0] > h - tx.y + crop[3])   discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y > h - crop[3]) discard;
		
	} else if(edge == 9) {
		if(fullEdge == 0 && tx.x < tx.y) discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y > h - crop[3]) discard;
		
	} else if(edge == 6) {
		if(fullEdge == 0 && tx.x < h - tx.y) discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y < crop[1]) discard;
		
	} else {
		discard;
	}
	
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
}
