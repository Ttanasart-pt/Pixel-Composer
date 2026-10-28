varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float radius;

void main() {
	vec2 tx = 1. / dimension;
	float w = 0.;
	float t = 0.;

	for(float x = -radius; x <= radius; x++)
	for(float y = -radius; y <= radius; y++) {
		vec2  sm  = vec2(x, y) * tx;
		float dis = 1. - length(sm) / max(1., radius);

		w += dis * texture2D(gm_BaseTexture, v_vTexcoord + sm).r;
		t += dis;
	}

	w /= t;	
	gl_FragColor = vec4(w, w, w, 1.);
}