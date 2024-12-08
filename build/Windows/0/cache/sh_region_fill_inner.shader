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

#define ITERATION 8.

uniform vec2  dimension;

vec4 sample ( vec2 position ) {
	if(position.x < 0. || position.y < 0. || position.x > 1. || position.y > 1.) return vec4(1., 1., 1., 1.);
	return texture2D( gm_BaseTexture, position );
}

void main() {
	vec2 tx = 1. / dimension;
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(gl_FragColor.b == 1.) return;
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec4 s = sample( v_vTexcoord + vec2(tx.x * i, 0) );
		
		if(s.a == 0.) break;
		if(s.b == 0.) continue;
		
		gl_FragColor.b = 1.;
		return;
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec4 s = sample( v_vTexcoord - vec2(tx.x * i, 0) );
		
		if(s.a == 0.) break;
		if(s.b == 0.) continue;
		
		gl_FragColor.b = 1.;
		return;
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec4 s = sample( v_vTexcoord + vec2(0, tx.y * i) );
		
		if(s.a == 0.) break;
		if(s.b == 0.) continue;
		
		gl_FragColor.b = 1.;
		return;
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec4 s = sample( v_vTexcoord - vec2(0, tx.y * i) );
		
		if(s.a == 0.) break;
		if(s.b == 0.) continue;
		
		gl_FragColor.b = 1.;
		return;
	}
}

