//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec4 bbox;
uniform int  mode;

uniform sampler2D texture;

void main() {
	float _w = dimension.x;
	float _h = dimension.y;
	vec4 col;
	float i, j;
	
	if(mode == 0) { //minx
		for( i = 0.; i < _w; i++ )
		for( j = 0.; j < _h; j++ ) {
			col = texture2D( texture, vec2(i, j) / dimension);
			if(col.r > 0.) {
				gl_FragColor = vec4(i);
				return;
			}
		}
	} else if(mode == 1) { //miny
		for( i = 0.; i < _h; i++ )
		for( j = bbox.x; j < _w; j++ ) {
			col = texture2D( texture, vec2(j, i) / dimension);
			if(col.r > 0.) {
				gl_FragColor = vec4(i);
				return;
			}
		}
	} else if(mode == 2) { //maxx
		for( i = _w; i > bbox.x; i-- )
		for( j = bbox.y; j < _h; j++ ) {
			col = texture2D( texture, vec2(i, j) / dimension);
			if(col.r > 0.) {
				gl_FragColor = vec4(i);
				return;
			}
		}
	} else if(mode == 3) { //maxy
		for( i = _h; i > bbox.y; i-- )
		for( j = bbox.x; j < bbox.z; j++ ) {
			col = texture2D( texture, vec2(j, i) / dimension);
			if(col.r > 0.) {
				gl_FragColor = vec4(i);
				return;
			}
		}
	} 
}
