varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform sampler2D fore;
uniform float opacity;

void main() {
	vec4 _col0 = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 _col1 = texture2D( fore, v_vTexcoord );
	_col0.a -= _col1.a;
	gl_FragColor = _col0;
}
