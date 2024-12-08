//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;

varying float zDist;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    zDist = length((gm_Matrices[MATRIX_WORLD] * object_space_pos).xyz);
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
//
// Simple passthrough fragment shader
//
varying float zDist;

void main() {
	float dist = 1. - (zDist - 1.) / 100.;
	gl_FragColor = vec4(vec3(dist), 1.);
}

