varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 threshold;

void main() {
	vec4  c = texture2D( gm_BaseTexture, v_vTexcoord );
	float a = (c.r + c.g + c.b) / 3.;
	
    gl_FragColor = vec4(vec3(smoothstep(threshold[0], threshold[1], a)), 1.);
}
