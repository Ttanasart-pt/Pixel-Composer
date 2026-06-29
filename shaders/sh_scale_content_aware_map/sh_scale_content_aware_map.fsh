varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D coordSurf;
uniform sampler2D oriSurf;

void main() {
	vec2 coord   = texture2D(coordSurf, v_vTexcoord).xy;
	gl_FragColor = texture2D(oriSurf, coord);
}