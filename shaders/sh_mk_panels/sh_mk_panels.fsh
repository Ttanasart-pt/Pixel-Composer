varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 position;
uniform vec2 dimension;

uniform vec4  corner;
uniform int   style;

void main() {
	vec2 px = floor(v_vTexcoord * dimension);
	vec2 tx = floor(position + px);
	vec4 cc = v_vColour;
	
	float cr0 = floor(min(dimension.x, dimension.y) * corner[0]) - 1.;
	float cr1 = floor(min(dimension.x, dimension.y) * corner[1]);
	float cr2 = floor(min(dimension.x, dimension.y) * corner[2]);
	float cr3 = floor(min(dimension.x, dimension.y) * corner[3]) + 1.;
	
	float pc0 = clamp((              cr0) - (              px.y), 0., dimension.x);
	float pc1 = clamp((dimension.x - cr1) + (              px.y), 0., dimension.x);
	float pc2 = clamp((              cr2) - (dimension.y - px.y), 0., dimension.x);
	float pc3 = clamp((dimension.x - cr3) + (dimension.y - px.y), 0., dimension.x);
	
	if(style == 1) {
		float _pc0 = pc0 / cr0;                 pc0 =               (1. - sqrt(1. - _pc0 * _pc0)) * cr0;
		float _pc1 = (dimension.x - pc1) / cr1; pc1 = dimension.x - (1. - sqrt(1. - _pc1 * _pc1)) * cr1;
		float _pc2 = pc2 / cr2;                 pc2 =               (1. - sqrt(1. - _pc2 * _pc2)) * cr2;
		float _pc3 = (dimension.x - pc3) / cr3; pc3 = dimension.x - (1. - sqrt(1. - _pc3 * _pc3)) * cr3;
	}
	
	if(corner[0] > 0. && px.x < pc0) cc = vec4(0.);
	if(corner[1] > 0. && px.x > pc1) cc = vec4(0.);
	if(corner[2] > 0. && px.x < pc2) cc = vec4(0.);
	if(corner[3] > 0. && px.x > pc3) cc = vec4(0.);
	
	gl_FragColor = cc;
}