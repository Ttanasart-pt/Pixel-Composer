varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float matrix[9];
uniform float intensity;

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 cb = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 cc = cb;
	
	cc.r = cc.r * matrix[0] + cc.g * matrix[1] + cc.b * matrix[2];
	cc.g = cc.r * matrix[3] + cc.g * matrix[4] + cc.b * matrix[5];
	cc.b = cc.r * matrix[6] + cc.g * matrix[7] + cc.b * matrix[8];
	
	gl_FragColor = vec4(mix(cb.rgb, cc.rgb, intensity), cb.a);
}