varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 position;
uniform vec2 dimension;

uniform vec4  corner;

void main() {
	vec2 px = floor(v_vTexcoord * dimension);
	vec2 tx = floor(position + px);
	vec4 cc = v_vColour;
	
	float cr0 = floor(min(dimension.x, dimension.y) * corner[0]) - 1.;
	float cr1 = floor(min(dimension.x, dimension.y) * corner[1]);
	float cr2 = floor(min(dimension.x, dimension.y) * corner[2]);
	float cr3 = floor(min(dimension.x, dimension.y) * corner[3]) + 1.;
	
	float pc0 =               cr0 -                px.y;
	float pc1 = dimension.x - cr1 +                px.y;
	float pc2 =               cr2 - (dimension.y - px.y);
	float pc3 = dimension.x - cr3 + (dimension.y - px.y);
	
	if(corner[0] > 0. && px.x < pc0) cc = vec4(0.);
	if(corner[1] > 0. && px.x > pc1) cc = vec4(0.);
	if(corner[2] > 0. && px.x < pc2) cc = vec4(0.);
	if(corner[3] > 0. && px.x > pc3) cc = vec4(0.);
	
	gl_FragColor = cc;
}