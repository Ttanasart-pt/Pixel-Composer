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
uniform vec4 padding;

vec4 sample ( vec2 position ) {
	if(position.x < 0.) return vec4(0.);
	if(position.y < 0.) return vec4(0.);
	if(position.x > 1.) return vec4(0.);
	if(position.y > 1.) return vec4(0.);
	
	return texture2D( gm_BaseTexture, position );
}

void main() {
	vec2 tx = 1. / dimension;
	vec2 pos;
	
    gl_FragColor = sample( v_vTexcoord );
	if(gl_FragColor.a == 0.) return;
	
	for(float i = 1.; i <= padding[0]; i++) {
		pos = v_vTexcoord + vec2( tx.x, 0. ) * i;
		if(sample(pos).a == 0.) {
			gl_FragColor = v_vColour;
			return;
		}
	}
	
	for(float i = 1.; i <= padding[1]; i++) {
		pos = v_vTexcoord + vec2( 0.,-tx.y ) * i;
		if(sample(pos).a == 0.) {
			gl_FragColor = v_vColour;
			return;
		}
	}
	
	for(float i = 1.; i <= padding[2]; i++) {
		pos = v_vTexcoord + vec2(-tx.x, 0. ) * i;
		if(sample(pos).a == 0.) {
			gl_FragColor = v_vColour;
			return;
		}
	}
	
	for(float i = 1.; i <= padding[3]; i++) {
		pos = v_vTexcoord + vec2( 0., tx.y ) * i;
		if(sample(pos).a == 0.) {
			gl_FragColor = v_vColour;
			return;
		}
	}
}

