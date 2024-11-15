varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#ifdef _YY_HLSL11_ 
	#define MAXPATH 1024
#else 
	#define MAXPATH 256
#endif

uniform vec4 color;
uniform vec4 bgColor;
uniform vec2 dimension;
uniform vec2 path[MAXPATH];
uniform int  pathLength;
uniform int  side;
uniform int  mirror;
uniform int  aa;
uniform int  bg;
uniform int  mode;

void main() {
	vec2  px = v_vTexcoord * dimension;
	vec2  dm = dimension;
	float it = 0.;
	float ds = 999999.;
	
	gl_FragColor = vec4(0.);
	
	if(side > 1) {
		px = px.yx;
		dm = dm.yx;
	}
	if(mirror == 1 && px.x < dm.x / 2.) px.x = dm.x - px.x;
	if(side == 1 || side == 3) px.x = 1. - px.x;
	
	for(int i = 1; i < MAXPATH; i++) {
		if(i >= pathLength) break;
		
		vec2 p0 = path[i - 1];
		vec2 p1 = path[i];
		
		if(side > 1) {
			p0 = p0.yx;
			p1 = p1.yx;
		}
		
		if(side == 1 || side == 3) {
			p0.x = 1. - p0.x;
			p1.x = 1. - p1.x;
		}
		
		if(p0.x < px.x && p1.x < px.x) continue;
		if(p0.y < px.y && p1.y < px.y) continue;
		if(p0.y > px.y && p1.y > px.y) continue;
		
		float _s = (p1.x - p0.x) / (p1.y - p0.y);
		float _x = p0.x + _s * (px.y - p0.y);
		
		if(_x > px.x) it++;
		
		ds = min(ds, abs(px.x - _x));
	}
	
	bool fill = false;
	
		 if(mode == 0) fill = mod(it, 2.) == 1.;
	else if(mode == 1) fill = it > 0.;
	
	if(fill) {
		gl_FragColor = color;
		if(aa == 1) gl_FragColor.a *= min(1., ds);
	}
}
