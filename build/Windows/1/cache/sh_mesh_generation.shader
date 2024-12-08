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
uniform vec2 com;

void main() {
	vec2 posPx  = v_vTexcoord * dimension;
	vec2 lookAt = normalize(posPx - com) / dimension;
	float dist  = dimension.x + dimension.y;
	
	vec4 sam = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = vec4(sam.a);
	
	for(float i = 1.; i <= dist; i++) {
		vec2 pos = v_vTexcoord + lookAt * i;
		
		if(pos.x < 0. || pos.y < 0. || pos.x > 1. || pos.y > 1.)
			continue;
		
		vec4 sam = texture2D( gm_BaseTexture, pos );
		if(sam.a == 1.) { //inner pixel
			gl_FragColor = vec4(0.);
			break;
		}
	}
}

