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
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D map;
uniform vec2 mapDimension;
uniform int useMap;

uniform vec2 dimension;
uniform float ditherSize;
uniform float dither[64];
uniform float seed;

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy, vec2(1892.9898, 78.23453))) * (seed + 437.54123)); }

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(c.a == 1.) {
		gl_FragColor = c;
		return;
	}
	
	vec2 pos = floor(v_vTexcoord * dimension);
	float val;
	
	if(useMap == 0) {
		float col = mod(pos.x, ditherSize);
		float row = mod(pos.y, ditherSize);
	
		val = dither[int(row * ditherSize + col)] / (ditherSize * ditherSize - 1.);
		
	} else if(useMap == 1) {
		float col = mod(pos.x, mapDimension.x);
		float row = mod(pos.y, mapDimension.y);
		vec4 map_data = texture2D( map, vec2(col, row) / mapDimension );
		
		val = dot(map_data.rgb, vec3(0.2126, 0.7152, 0.0722));
		
	} else if(useMap == 2) {
		val = random(v_vTexcoord, seed);
		
	}
	
	c.a = c.a > val? 1. : 0.;
	
	gl_FragColor = c;
}

