varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float rotation;
uniform int   oversample;

float sampleDepth(vec2 pos) {
	     if(oversample == 0) pos = fract(fract(pos) + 1.);
	else if(oversample == 1) pos = clamp(pos, 0., 1.);
	
	vec4 sam = texture2D(gm_BaseTexture, pos);
	return sam.r * sam.a;
}

void main() {
	vec2 tx = 1. / dimension;
	vec2 grad = vec2(
		sampleDepth(v_vTexcoord + vec2(tx.x, 0.)) - sampleDepth(v_vTexcoord - vec2(tx.x, 0.)),
		sampleDepth(v_vTexcoord + vec2(0., tx.y)) - sampleDepth(v_vTexcoord - vec2(0., tx.y))
	);

	float ang = radians(rotation);
	grad = vec2(
		grad.x * cos(ang) - grad.y * sin(ang),
		grad.x * sin(ang) + grad.y * cos(ang)
	);

	gl_FragColor = vec4( grad, 0., 1. );
}