varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D surface;
uniform vec2  scale;
uniform float size;
uniform float frame;
uniform float progress;
uniform vec4  blend;

void main() {
	vec2 tx = v_vTexcoord * scale / size + frame * .01;
	     tx = fract(tx);
	
	gl_FragColor = vec4(blend.rgb, progress) * texture2D(surface, tx);
}