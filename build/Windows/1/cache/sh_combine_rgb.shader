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

uniform int mode;
uniform sampler2D samplerR;
uniform sampler2D samplerG;
uniform sampler2D samplerB;
uniform sampler2D samplerA;

uniform int useR;
uniform int useG;
uniform int useB;
uniform int useA;

uniform vec2      base;
uniform int       baseUseSurf;
uniform sampler2D baseSurf;

float sample(vec4 col, int ch) {
	if(mode == 0) return (col[0] + col[1] + col[2]) / 3. * col[3];
	return col[ch];
}

void main() {
	float bse = base.x;
	if(baseUseSurf == 1) {
		vec4 _vMap = texture2D( baseSurf, v_vTexcoord );
		bse = mix(base.x, base.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float r = (useR == 1)? sample(texture2D( samplerR, v_vTexcoord ), 0) : bse;
	float g = (useG == 1)? sample(texture2D( samplerG, v_vTexcoord ), 1) : bse;
	float b = (useB == 1)? sample(texture2D( samplerB, v_vTexcoord ), 2) : bse;
	float a = (useA == 1)? sample(texture2D( samplerA, v_vTexcoord ), 3) : 1.;
	
	gl_FragColor = vec4(r, g, b, a);
}

