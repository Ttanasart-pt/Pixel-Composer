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
vec2 tx;

bool sample(float x, float y) {
	vec2 pos = v_vTexcoord + vec2(tx.x * x, tx.y * y);
	if(pos.x < 0. || pos.y < 0. || pos.x > 1. || pos.y > 1.) return true;
	
	vec4 c = texture2D( gm_BaseTexture, pos );
	return (c.r + c.g + c.b) * c.a == 0.;
}

void main() {
	tx = 1. / dimension;
	vec4 cc = texture2D( gm_BaseTexture, v_vTexcoord );
	
    gl_FragColor = vec4(0.);
	if(cc.a == 0.) return;
	
	bool s1 = sample(-1., 0.);
	bool s2 = sample( 1., 0.);
	bool s3 = sample(0., -1.);
	bool s4 = sample(0.,  1.);
	
	if(s1 && s2) return;
	if(s3 && s4) return;
	
	if(s1) { gl_FragColor = vec4(1.); return; }
	if(s2) { gl_FragColor = vec4(1.); return; }
	if(s3) { gl_FragColor = vec4(1.); return; }
	if(s4) { gl_FragColor = vec4(1.); return; }
}

