attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)

varying vec4 v_vColour;
varying vec2 v_vPosition;

uniform vec2  ballPos;
uniform float ballRad;
uniform vec3  ballShift;

void main() {
	vec3 ballPosition = in_Position + ballShift;
    vec4 object_space_pos = vec4( ballPosition, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour   = in_Colour;
	v_vPosition = (in_Position.xy - ballPos) / ballRad;
}
