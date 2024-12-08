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

uniform float tolerance;
uniform int   useMask;
uniform sampler2D mask;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

uniform vec4 colorTarget[PALETTE_LIMIT];
uniform int colorTargetAmount;

void main() {
	vec4 c1 = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = vec4(0.);
	
	if(useMask == 1) {
		vec4 m = texture2D( mask, v_vTexcoord );
		if((m.r + m.g + m.b) * m.a < 0.5) 
			return;
	}
	
	float minDist = 10.;
	for(int i = 0; i < colorTargetAmount; i++) {
		float dist = distance(colorTarget[i].rgb, c1.rgb);
		minDist = min(minDist, dist);
	}
	
	if(minDist > tolerance) return;
	
	gl_FragColor = vec4(v_vTexcoord, 1., 1.);
}

