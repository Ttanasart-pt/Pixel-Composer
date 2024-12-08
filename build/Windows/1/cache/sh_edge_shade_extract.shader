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
#define PI 3.14159265359

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	vec2 tx = 1. / dimension;
	
	gl_FragColor = vec4(0.);
	
	float c4 = texture2D( gm_BaseTexture, v_vTexcoord).r;
	if(c4 == 0.) return; 
	
	float c;
	vec2  p = v_vTexcoord - 0.5;	
	
	float a = atan(p.y, p.x) / PI;
	if(a < 0.) a = 2. + a;
	a /= 2.;
	
	c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, -tx.y) ).r; if(c == 0.) { gl_FragColor = vec4(a, 0., 0., 1.); return; }
	c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(   0., -tx.y) ).r; if(c == 0.) { gl_FragColor = vec4(a, 0., 0., 1.); return; }
	c = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, -tx.y) ).r; if(c == 0.) { gl_FragColor = vec4(a, 0., 0., 1.); return; }
	
	c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,    0.) ).r; if(c == 0.) { gl_FragColor = vec4(a, 0., 0., 1.); return; }
	c = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x,    0.) ).r; if(c == 0.) { gl_FragColor = vec4(a, 0., 0., 1.); return; }
	
	c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,  tx.y) ).r; if(c == 0.) { gl_FragColor = vec4(a, 0., 0., 1.); return; }
	c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(   0.,  tx.y) ).r; if(c == 0.) { gl_FragColor = vec4(a, 0., 0., 1.); return; }
	c = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x,  tx.y) ).r; if(c == 0.) { gl_FragColor = vec4(a, 0., 0., 1.); return; }
}

