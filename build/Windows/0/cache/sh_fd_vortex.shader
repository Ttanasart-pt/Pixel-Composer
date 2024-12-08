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

uniform float vortex;
uniform float angleIO;

void main() {
	float inCircle = length(v_vTexcoord - vec2(0.5));
	
	if(inCircle > 0.5) { gl_FragColor = vec4(0.); return; }
	
	vec2  pos   = v_vTexcoord - vec2(0.5);
	float rad   = inCircle * 2.;
	float angle = atan(pos.y, pos.x) + (PI / 2. + angleIO * PI / 2.);
	float dist  = (1. - rad) * vortex;
	
	gl_FragColor = vec4(cos(angle) * dist, sin(angle) * dist, 0., 1.);
}

