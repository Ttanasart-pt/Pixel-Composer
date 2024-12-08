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
#define TAU 6.283185307179586

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float strength;
uniform vec2  center;
uniform float radius;

uniform float spokes;
uniform float rotate;

void main() {
	vec2  pos   = v_vTexcoord - center;
	float rad   = length(pos);
	float dist  = rad * strength;
	float drad  = smoothstep(radius * strength, 0., dist);
	
	float angle = atan(pos.y, pos.x);
	if(spokes != 0.) {
		float sp = TAU / spokes;
		angle = floor(angle / sp) * sp + sp * .5 + rotate;
	}
	
	gl_FragColor = vec4(cos(angle) * dist * drad, sin(angle) * dist * drad, 0., 1.);
}

