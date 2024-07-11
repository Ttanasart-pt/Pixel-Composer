varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int alpha;

void main() {
	vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	
		 if(alpha == 0) gl_FragColor = vec4(1. - c.rgb, c.a);
	else if(alpha == 1) gl_FragColor = 1. - c;
}
