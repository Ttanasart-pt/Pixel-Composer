//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float threshold;
uniform int   ignore;
uniform int   mode;
uniform sampler2D map;

vec4 sampVal(vec4 col) { return mode == 1? vec4(col.a) : col; }

void main() {
	vec4 baseCol = sampVal(texture2D( map, v_vTexcoord ));
	
	if(ignore == 1 && baseCol == vec4(0.)) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	vec2 tx = 1. / dimension;
	vec4 _c = texture2D( gm_BaseTexture, v_vTexcoord );
	vec2 _index_min = _c.xy;
	vec2 _index_max = _c.zw;
	
	for(float i = -1.; i <= 1.; i++)
	for(float j = -1.; j <= 1.; j++) {
		vec2 pos   = clamp(v_vTexcoord + vec2(i, j) * tx, 0., 1.);
		vec4 samCl = sampVal(texture2D( map, pos ));
		
		if(ignore == 1 && samCl == vec4(0.)) continue;
		
		if(distance(samCl, baseCol) <= threshold) {
			vec4 _col = texture2D( gm_BaseTexture, pos );
			_index_min.x = min(_index_min.x, _col.r);
			_index_min.y = min(_index_min.y, _col.g);
				
			_index_max.x = max(_index_max.x, _col.b);
			_index_max.y = max(_index_max.y, _col.a);
		}
	}
	gl_FragColor = vec4(_index_min, _index_max );
}

