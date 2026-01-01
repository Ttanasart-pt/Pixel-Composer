varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float matrix[9];
uniform float intensity;

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 cb = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 cc = cb;
	
	cc.r = cb.r * matrix[0] + cb.g * matrix[1] + cb.b * matrix[2];
	cc.g = cb.r * matrix[3] + cb.g * matrix[4] + cb.b * matrix[5];
	cc.b = cb.r * matrix[6] + cb.g * matrix[7] + cb.b * matrix[8];
	
	gl_FragColor = vec4(mix(cb.rgb, cc.rgb, intensity), cb.a);
}