varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float k;
uniform float thres;

uniform sampler2D Ixx;
uniform sampler2D Ixy;
uniform sampler2D Iyy;

void main() {
	vec2 tx = 1. / dimension;
	float g = texture2D(gm_BaseTexture, v_vTexcoord).r;

	float ixx = texture2D(Ixx, v_vTexcoord).r;
	float ixy = texture2D(Ixy, v_vTexcoord).r;
	float iyy = texture2D(Iyy, v_vTexcoord).r;

	mat2 M = g * mat2( ixx, ixy,
		               ixy, iyy );
	
	float detM   = (M[0][0] * M[1][1] - M[0][1] * M[1][0]);
	float traceM = (M[0][0] + M[1][1]);

	float R = detM - k * traceM * traceM;
	float w = step(thres, R);

	gl_FragColor = v_vColour * vec4(w, w, w, 1.);
}