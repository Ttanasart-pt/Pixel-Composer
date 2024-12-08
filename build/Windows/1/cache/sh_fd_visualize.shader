// Passthrough vertex shader.

attribute vec4 in_Position;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
    v_vTexcoord = in_TextureCoord;
    v_vColour = in_Colour;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	float a = texture2D(gm_BaseTexture, v_vTexcoord).a;
    gl_FragColor = vec4(vec3(1.), a);
}

