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

uniform vec4  color;
uniform float intensity;
uniform float band;

uniform int   atten;
uniform float exponent;

void main() {
	vec4  samp   = texture2D( gm_BaseTexture, v_vTexcoord);
	float bright = (samp.r + samp.b + samp.g) / 3.;
	
		 if(atten == 0) bright = pow(bright, exponent);
	else if(atten == 1) bright = 1. - pow(1. - bright, exponent);
	else if(atten == 2) bright = bright;
	bright *= intensity;
		
	if(band > 0.) bright = ceil(bright * band) / band;
	
    gl_FragColor = vec4(color.rgb * bright, 1.);
}

