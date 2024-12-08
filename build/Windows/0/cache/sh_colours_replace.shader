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
#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 colorFrom[PALETTE_LIMIT];
uniform int  colorFromAmount;

uniform vec4 colorTo[PALETTE_LIMIT];
uniform int  colorToAmount;

uniform int  useMask;
uniform sampler2D mask;

void main() {
	vec4 p = texture2D( gm_BaseTexture, v_vTexcoord );
	
	int index = 0;
	float minDist = 999.;
	
	for(int i = 0; i < colorFromAmount; i++ ) {
		float dist = distance(p.rgb, colorFrom[i].rgb);
		if(dist < minDist) {
			minDist = dist;
			index = i;
		}
	}
	
    gl_FragColor = vec4(colorTo[index].rgb, p.a * colorTo[index].a);
}

