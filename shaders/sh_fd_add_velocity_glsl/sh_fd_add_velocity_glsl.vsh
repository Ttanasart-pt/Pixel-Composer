attribute vec4 in_Position;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour;

varying vec2 v_vTexcoord;
varying vec2 v_vScreencoord;
varying vec4 color;

uniform vec2 addend;

void main() {
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
    v_vTexcoord = in_TextureCoord;
    v_vScreencoord = gl_Position.xy * vec2(0.5, -0.5) + addend;
    color = in_Colour;
}
