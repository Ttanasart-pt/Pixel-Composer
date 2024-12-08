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
	#define SHAPE_LIMIT 1024 
#else 
	#define SHAPE_LIMIT 256 
#endif

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D surface;
uniform int maxShape;
uniform int ignore;

void main() {
	vec4 zero  = vec4(0.);
	vec2 pxPos = v_vTexcoord * vec2(float(maxShape), 1.) - 0.5;
	
	int amo = 0;
	vec4 list[SHAPE_LIMIT];
	
	for(float i = 0.; i <= dimension.x; i++)
	for(float j = 0.; j <= dimension.y; j++) {
		if(amo > maxShape) break;
		
		vec4 col = texture2D( surface, vec2(i, j) / dimension );
		if(ignore == 1 && col == zero) continue;
		
		bool dup = false;	
		for(int k = 0; k < amo; k++) {
			if(col == list[k]) {
				dup = true;
				break;
			}
		}
		
		if(dup) continue;
		
		if(floor(pxPos.x - 1.) == float(amo)) {
			gl_FragColor = col;
			return;
		}
		list[amo] = col;
		amo++;
	}
	
	if(floor(pxPos.x) == 0.) gl_FragColor = vec4(amo, 0., 0., 0.);
}

