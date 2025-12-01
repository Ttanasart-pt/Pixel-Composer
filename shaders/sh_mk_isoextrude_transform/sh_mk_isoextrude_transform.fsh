varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float rotation;
uniform vec2  scale;

void main() {
	vec2  tx  = v_vTexcoord;
	float rot = radians(rotation);
	
	tx = .5 + (tx - .5) / scale * mat2(cos(rot), -sin(rot), sin(rot), cos(rot));
	
	gl_FragColor = v_vColour * texture2D(gm_BaseTexture, tx);
}