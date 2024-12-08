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
#define TAU 6.28318530718

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float radius;
uniform float threshold;

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = vec4(0.);
	float av = 0., dv = 0.;
	
	float stp = TAU / 64.;
	
	for(float i = 0.; i < radius; i++)
	for(float j = 0.; j < TAU; j += stp) {
		vec2 sx = v_vTexcoord + vec2(cos(j), sin(j)) * tx * i;
		
		vec4 c = texture2D( gm_BaseTexture, sx );
		
		cc += c;
		dv += 1.;
		av += c.a;
	}
	
	cc /= dv;
	
    gl_FragColor = step(threshold, cc);
}

