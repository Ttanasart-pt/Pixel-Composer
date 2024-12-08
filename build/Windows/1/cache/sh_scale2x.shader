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
uniform float tol;

bool eq(in vec4 c1, in vec4 c2) {
	return distance(c1, c2) <= tol;
}

void main() {
	vec2 pixel = 1. / dimension;
	
	vec2 tex_pos = v_vTexcoord;
	vec2 pos_B = clamp(tex_pos + vec2(       0, -pixel.y), 0., 1.);
	vec2 pos_D = clamp(tex_pos + vec2(-pixel.x,        0), 0., 1.);
	vec2 pos_F = clamp(tex_pos + vec2( pixel.x,        0), 0., 1.);
	vec2 pos_H = clamp(tex_pos + vec2(       0,  pixel.y), 0., 1.);
	
	vec4 E = texture2D( gm_BaseTexture, tex_pos);
	vec4 B = texture2D( gm_BaseTexture, pos_B);
	vec4 D = texture2D( gm_BaseTexture, pos_D);
	vec4 F = texture2D( gm_BaseTexture, pos_F);
	vec4 H = texture2D( gm_BaseTexture, pos_H);
	
	vec2 rem = floor(fract(tex_pos * dimension) * 2.);
	float index = rem.y * 2. + rem.x;
	
	if(!eq(B, H) && !eq(D, F)) {
		if(index == 0.)		 gl_FragColor = eq(D, B)? D : E;
		else if(index == 1.) gl_FragColor = eq(B, F)? F : E;
		else if(index == 2.) gl_FragColor = eq(D, H)? D : E;
		else				 gl_FragColor = eq(H, F)? F : E;
	} else {
		gl_FragColor = E;
	}
}

