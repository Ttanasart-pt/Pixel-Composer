//
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

#define TAU 6.283185307179586
#define pi1 3.14159
#define pi2 1.57079

uniform vec2  dimension;
uniform vec2  position;
uniform float angle;

float angle_different(in float a1, in float a2) { 
	float _d = (a2 - a1) + pi2;
	return (_d - floor(_d / pi1) * pi1) - pi2;
} 

void main() {
	vec2  pos = v_vTexcoord;
	vec2  pixel_pos = v_vTexcoord * dimension;
	float _angle;
	
	_angle = atan((pixel_pos.y - position.y), (pixel_pos.x - position.x)) + angle;
	_angle = TAU - (_angle - floor(_angle / TAU) * TAU); 
	
	if(_angle < pi1) {
		float _alpha    = (angle + pi1) - (_angle + angle);
		float inv_angle = (angle + pi1) + _alpha;
		float dist      = distance(pixel_pos, position);
		
		pos = (position + vec2(cos(inv_angle) * dist, -sin(inv_angle) * dist )) / dimension;
	} 
	
	gl_FragColor = vec4(0.);
	if(pos.x > 0. && pos.x < 1. && pos.y > 0. && pos.y < 1.)
		gl_FragColor = v_vColour * texture2D( gm_BaseTexture, pos );
}

