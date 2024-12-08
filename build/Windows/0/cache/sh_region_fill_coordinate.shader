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

#define ITERATION 4.

uniform sampler2D base;
uniform vec2  dimension;

void main() {
	vec2 tx = 1. / dimension;
    vec4 c  = texture2D( gm_BaseTexture, v_vTexcoord );
    vec4 b  = texture2D( base, v_vTexcoord );
	
	gl_FragColor = vec4(0.);
	
	if(b.a == 0.) return;
	
	gl_FragColor = c;
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec2 x = v_vTexcoord + vec2(tx.x * i, 0);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		vec4 b = texture2D( base,           x );
		
		if(b.a == 0.) break;
		
		gl_FragColor.xy = min( gl_FragColor.xy, s.xy );
		gl_FragColor.zw = max( gl_FragColor.zw, s.zw );
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec2 x = v_vTexcoord - vec2(tx.x * i, 0);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		vec4 b = texture2D( base,           x );
		
		if(b.a == 0.) break;
		
		gl_FragColor.xy = min( gl_FragColor.xy, s.xy );
		gl_FragColor.zw = max( gl_FragColor.zw, s.zw );
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec2 x = v_vTexcoord + vec2(0, tx.y * i);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		vec4 b = texture2D( base,           x );
		
		if(b.a == 0.) break;
		
		gl_FragColor.xy = min( gl_FragColor.xy, s.xy );
		gl_FragColor.zw = max( gl_FragColor.zw, s.zw );
	}
	
	for( float i = 1.; i < ITERATION; i++ ) {
		vec2 x = v_vTexcoord - vec2(0, tx.y * i);
		if(x.x < 0. || x.y < 0. || x.x > 1. || x.y > 1.) break;
		
		vec4 s = texture2D( gm_BaseTexture, x );
		vec4 b = texture2D( base,           x );
		
		if(b.a == 0.) break;
		
		gl_FragColor.xy = min( gl_FragColor.xy, s.xy );
		gl_FragColor.zw = max( gl_FragColor.zw, s.zw );
	}
}

