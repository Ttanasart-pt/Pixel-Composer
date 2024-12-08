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
uniform vec2 sampler;

void main() {
	vec2 pos = floor((v_vTexcoord * dimension) / sampler) * sampler;
	pos /= dimension;
	
	gl_FragColor = vec4(0.);
	
	for(float i = 0.; i <= sampler.x; i++)
	for(float j = 0.; j <= sampler.y; j++) {
		vec4 col = texture2D( gm_BaseTexture, pos + vec2(i, j) / dimension);
		if(col.a > 0.) {
			gl_FragColor = vec4(1.);
			return;
		}
	}
}

