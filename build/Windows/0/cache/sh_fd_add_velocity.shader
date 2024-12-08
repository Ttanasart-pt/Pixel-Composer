attribute vec4 in_Position;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;

void main() {
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;

uniform vec2 velo;

void main() {
    vec4 velocity = texture2D(gm_BaseTexture, v_vTexcoord);
    velocity.xy  *= velo.xy;
    
    gl_FragColor = velocity;
}

