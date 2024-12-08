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

uniform vec2 dimension;

uniform int useMask;
uniform sampler2D mask;

vec2 tx;

vec4 sample(float x, float y, vec4 c4) {
	vec4 c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(x, y) * tx ); 
	
	if(c.a > 0.) { 
		c4.rgb = min(c4.rgb, c.rgb);
		
		if(useMask == 1) {
			vec4 m = texture2D( mask, v_vTexcoord + vec2(x, y) * tx ); 
			if(m.r == 0.) c4.b = 0.;
		}
	}
	
	return c4;
}

void main() {
	tx = 1. / dimension;
	gl_FragColor = vec4(0.);
	
	vec4 c4 = texture2D( gm_BaseTexture, v_vTexcoord );
	if(c4.a == 0.) return;
	
	if(useMask == 1) {
		vec4 m = texture2D( mask, v_vTexcoord ); 
		if(m.r == 0.) c4.b = 0.;
	}
		
	c4 = sample(-1., -1., c4);
	c4 = sample(-1.,  0., c4);
	c4 = sample(-1.,  1., c4);
	
	c4 = sample( 0., -1., c4);
	c4 = sample( 0.,  1., c4);
	
	c4 = sample( 1., -1., c4);
	c4 = sample( 1.,  0., c4);
	c4 = sample( 1.,  1., c4);
	
	gl_FragColor = c4;
	
}

