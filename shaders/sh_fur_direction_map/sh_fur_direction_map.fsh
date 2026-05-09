varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
#define PI 3.1415926535897932384626433832795

// calculate flow direction (perpendicular to gradient)
void main() {
	vec2 tx = 1. / dimension;

	vec4 cx0 = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.));
	vec4 cx1 = texture2D(gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.));
	vec4 cy0 = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0., -tx.y));
	vec4 cy1 = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.,  tx.y));

	vec2 grad  = vec2(cx1.r - cx0.r, cy1.r - cy0.r);
	float dirr = atan(grad.y, grad.x) / (2. * PI) + 0.5;
	
	gl_FragColor = vec4(dirr, 0., 0., 1.);
}