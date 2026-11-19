attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour;
attribute vec3 in_Barycentric;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float scale;

void main() {
	vec2 tuv     = in_TextureCoord / scale;
	     tuv     = (tuv - .5) * 2.;
	     tuv.y   = -tuv.y;
	     
	gl_Position = vec4(tuv, 0., 1.);
	v_vColour   = in_Colour;
	v_vTexcoord = in_TextureCoord / scale;
}