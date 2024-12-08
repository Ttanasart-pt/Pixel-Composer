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
uniform int corner;
uniform int side;

vec4 sample ( vec2 position ) {
	if(position.x < 0.) return vec4(0.);
	if(position.y < 0.) return vec4(0.);
	if(position.x > 1.) return vec4(0.);
	if(position.y > 1.) return vec4(0.);
	
	return texture2D( gm_BaseTexture, position );
}

void main() {
	vec2 tx = 1. / dimension;
	
    gl_FragColor = sample( v_vTexcoord );
	float _s = float(side);
	
	if(gl_FragColor.a == _s) return;
	
	bool a0 = sample( v_vTexcoord + vec2( -tx.x, -tx.y) ).a == _s;
	bool a1 = sample( v_vTexcoord + vec2(    0., -tx.y) ).a == _s;
	bool a2 = sample( v_vTexcoord + vec2(  tx.x, -tx.y) ).a == _s;
				   
	bool a3 = sample( v_vTexcoord + vec2( -tx.x,    0.) ).a == _s;
	bool a5 = sample( v_vTexcoord + vec2(  tx.x,    0.) ).a == _s;
				   
	bool a6 = sample( v_vTexcoord + vec2( -tx.x,  tx.y) ).a == _s;
	bool a7 = sample( v_vTexcoord + vec2(    0.,  tx.y) ).a == _s;
	bool a8 = sample( v_vTexcoord + vec2(  tx.x,  tx.y) ).a == _s;
	
	if( a1 || a3 || a5 || a7 ) 
		gl_FragColor = v_vColour;
	if( corner == 1 && ( a0 || a2 || a6 || a8 ) ) 
		gl_FragColor = v_vColour;
}

