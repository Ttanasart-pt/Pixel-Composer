attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)

varying vec4 v_vColour;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec4 v_vColour;
uniform vec4 blend;

void main() {
    gl_FragColor = v_vColour * blend;
}

