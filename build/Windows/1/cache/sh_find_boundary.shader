//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
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
			if(col.a > 0.) {
				gl_FragColor = vec4(i);
				return;
			}
		}
	} else if(mode == 1) { //miny
		for( i = 0.; i < _h; i++ )
		for( j = bbox.x; j < _w; j++ ) {
			col = texture2D( texture, vec2(j, i) / dimension);
			if(col.a > 0.) {
				gl_FragColor = vec4(i);
				return;
			}
		}
	} else if(mode == 2) { //maxx
		for( i = _w; i >= bbox.x; i-- )
		for( j = bbox.y; j < _h; j++ ) {
			col = texture2D( texture, vec2(i, j) / dimension);
			if(col.a > 0.) {
				gl_FragColor = vec4(i);
				return;
			}
		}
	} else if(mode == 3) { //maxy
		for( i = _h; i >= bbox.y; i-- )
		for( j = bbox.x; j <= bbox.z; j++ ) {
			col = texture2D( texture, vec2(j, i) / dimension);
			if(col.a > 0.) {
				gl_FragColor = vec4(i);
				return;
			}
		}
	} 
}

