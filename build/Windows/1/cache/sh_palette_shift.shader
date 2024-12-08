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

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif
uniform vec4  palette[PALETTE_LIMIT];
uniform float paletteAmount;

uniform float shift;

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	
	float minDist = 999.;
	float index   = 0.;
	
	for(float i = 0.; i < paletteAmount; i++) {
		float _dist = distance(c.rgb, palette[int(i)].rgb);
		if(_dist < minDist) {
			minDist = _dist;
			index   = i;
		}
	}
	
	index = mod(index + shift, paletteAmount);
	gl_FragColor = palette[int(index)];
}

