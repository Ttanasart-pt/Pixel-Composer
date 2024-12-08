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

uniform int attempt;
uniform float seed;
uniform vec2 dimension;

float random (in vec2 st, float _seed) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233)) * mod(_seed, 32.156) * 12.588) * 43758.5453123);
}

void main() {
	gl_FragColor = vec4(0.); 
	
	float v = 0.;
	for(int i = 0; i < attempt; i++) {
		float _x = random(vec2(i, 0.) + v_vTexcoord.x, 132.54664 + seed);
		float _y = random(vec2(0., i) + v_vTexcoord.x,  78.29131 + seed);
		float _w = random(vec2( i, i) + v_vTexcoord.x,   8.10684 + seed);
		
		vec4 col = texture2D( gm_BaseTexture, vec2(_x, _y) );
		float gr = (col.r + col.g + col.b) / 3.;
		float br = gr * col.a * _w;
		if(br > v) {
			v = br;
			gl_FragColor = vec4(_x, _y, gr, 1.);
		}
	}
}

