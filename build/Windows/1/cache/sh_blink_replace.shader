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

uniform float seed;
uniform float ratio;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

uniform int  usePalette;
uniform vec4 palette[PALETTE_LIMIT];
uniform int  paletteAmount;

float random (in vec2 st) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * (43758.5453123 + seed)); }

void main() {
	vec4 pos = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = vec4(0.);
	if(pos.z == 0. || pos.a == 0.) return;
	
    int   index = int(floor(random(pos.rg) * float(paletteAmount)));
    float rrat  = random(pos.rg + vec2(1.6193, 3.5341));
	if(rrat >= ratio) return; 
	
	gl_FragColor = palette[index];
}

