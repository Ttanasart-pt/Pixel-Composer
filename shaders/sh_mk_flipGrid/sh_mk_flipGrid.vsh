attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)

varying vec4 v_vColour;
varying vec2 v_vPosition;

uniform vec2 flipPos;
uniform vec2 flipSize;

void main() {
    vec4 object_space_pos = vec4( in_Position, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour   = in_Colour;
	v_vPosition = (in_Position.xy - flipPos) / flipSize;
}
