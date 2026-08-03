varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
					
uniform vec4  bbox;
uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

uniform sampler2D mask;
uniform sampler2D content;

void main() {
	vec2 tx = 1. / dimension;
	
	vec2 px = v_vTexcoord * dimension;
	px -= position;
	
	gl_FragData[0] = texture2D(mask,    px * tx);
	gl_FragData[1] = texture2D(content, px * tx);
}