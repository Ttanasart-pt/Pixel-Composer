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

uniform vec2 dimension;

vec4 sample( vec2 pos ) {
	if(pos.x < 0. || pos.y < 0.) return vec4(0.);
	if(pos.x > 1. || pos.y > 1.) return vec4(0.);
	
	return texture2D( gm_BaseTexture, pos );
}

void main() {
	vec2 tx = 1. / dimension;
	vec4 a = sample( v_vTexcoord );
	gl_FragColor = a;
	if(a.a == 0.) return;
	
	bool a1 = sample( v_vTexcoord + vec2(   .0, -tx.y) ).a == 1.;
	bool a3 = sample( v_vTexcoord + vec2(-tx.x,    .0) ).a == 1.;
	bool a4 = a.a == 1.;
	bool a5 = sample( v_vTexcoord + vec2( tx.x,    .0) ).a == 1.;
	bool a7 = sample( v_vTexcoord + vec2(   .0,  tx.y) ).a == 1.;
	
    // 0 1 2
	// 3 4 5
	// 6 7 8
	
	if(!a1 || !a3 || !a5 || !a7)
		gl_FragColor = vec4(0.);
}

