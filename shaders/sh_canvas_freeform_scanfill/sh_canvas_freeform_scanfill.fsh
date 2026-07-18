varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform vec2 points[1024];
uniform int  pointAmo;

uniform vec4 color;

bool isLeft(vec2 p, vec2 l0, vec2 l1) {
	if(l0.y == l1.y) return false;
	if(p.y < min(l0.y, l1.y) || p.y >= max(l0.y, l1.y)) return false;

	float x = (p.y - l0.y) * (l1.x - l0.x) / (l1.y - l0.y) + l0.x;
	return p.x < x;
}

bool isRight(vec2 p, vec2 l0, vec2 l1) {
	if(l0.y == l1.y) return false;
	if(p.y < min(l0.y, l1.y) || p.y >= max(l0.y, l1.y)) return false;

	float x = (p.y - l0.y) * (l1.x - l0.x) / (l1.y - l0.y) + l0.x;
	return p.x > x;
}

void main() {
	vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = samp;
	if(samp.a > 0.) return;
	
	vec2 tx = 1. / dimension;
	vec2 px = v_vTexcoord * dimension;
	
	bool fillL = false;
	bool fillR = false;

	for(int i = 0; i < pointAmo - 1; i++) {
		vec2 p0 = points[i];
		vec2 p1 = points[i+1];

		if(isLeft(px, p0, p1))
			fillL = !fillL;

		if(isRight(px, p0, p1))
			fillR = !fillR;
	}
	
	if(fillL && fillR) gl_FragColor = color;
}