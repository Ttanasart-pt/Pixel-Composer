varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int invert;

void main() {
	vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	c.rgb  = pow(c.rgb, invert == 1? vec3(2.2) : vec3(1. / 2.2));
	
    gl_FragColor = c;
}
