varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;

uniform vec2 dimension;
uniform vec2 matchDimension;
uniform vec2 replaceDimension;

uniform sampler2D matchSurface;
uniform sampler2D replaceSurface;

uniform float threshold;
uniform vec2  matchAnchor;
uniform float replaceChange;

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy + seed / 1000., vec2(1892.9898, 78.23453))) * 437.54123); }

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
}