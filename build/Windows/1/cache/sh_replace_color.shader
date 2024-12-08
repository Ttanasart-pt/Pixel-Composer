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

uniform vec2  dimension;
uniform vec2  shift;
uniform int   type;
uniform float angle;

void main() {
	vec4 c  = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 ca;
	
	if(type == 1) {
		ca = v_vColour;
	} else if(type == 2) {
		vec2 tx  = 1. / dimension;
		mat2 rot = mat2(cos(angle), -sin(angle), 
						sin(angle),  cos(angle));
		vec2 shf = rot * shift;
		vec2 px  = v_vTexcoord - shf;
		vec4 l   = texture2D( gm_BaseTexture, px);
		
		while(l == c) {
			px -= shf;
			l = texture2D( gm_BaseTexture, px);
			
			if(l.a == 0.) break;
			if(px.x < 0. || px.y < 0.) break;
			if(px.x > 1. || px.y > 1.) break;
		}
		
		if(c.a == 1. && l.a > 0.)
			ca = l * v_vColour;
	}
	
	vec4 cc = mix(c, ca, ca.a);
	gl_FragColor = vec4(cc.rgb, c.a);
}

