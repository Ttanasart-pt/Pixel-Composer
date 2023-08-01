//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int colors;
uniform int alpha;
uniform float gamma;

void main() {
	vec4 _col = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 c = _col;
	c = floor(pow(c, vec4(gamma)) * float(colors));
	c = pow(c / float(colors), vec4(1.0 / gamma));
	
	if(alpha == 1)	gl_FragColor = c;
	else			gl_FragColor = vec4(c.rgb, _col.a);
}
