//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int colors;
uniform float gamma;

void main() {
	vec4 _col = texture2D( gm_BaseTexture, v_vTexcoord );
	vec3 c = _col.rgb;
	c = floor(pow(c, vec3(gamma)) * float(colors));
	c = pow(c / float(colors), vec3(1.0 / gamma));
	gl_FragColor = vec4(c, _col.a);
}
