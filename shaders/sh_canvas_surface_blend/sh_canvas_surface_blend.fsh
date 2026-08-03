varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D bg;

uniform int       selecting;
uniform sampler2D selectSurf;
uniform sampler2D selectMask;

uniform int   layer;
uniform int   erase;
uniform vec4  color;

uniform int   mirror_x;
uniform int   mirror_y;
uniform float mirror_dx;
uniform float mirror_dy;

vec4 blend(vec4 bg, vec4 fg) {
	if(bg.a == 0.) return fg;
	
	float al = fg.a + bg.a * (1. - fg.a);
	if(al == 0.) return vec4(0.);
	
	vec4 res = ((fg * fg.a) + (bg * bg.a * (1. - fg.a))) / al;
	res.a = al;
	
	return res;
}

void main() {
	vec4 bgC = texture2D(bg, v_vTexcoord);
	vec4 fgC = texture2D(gm_BaseTexture, v_vTexcoord);
	
	if(mirror_x == 1) {
		float mirx = .5 + mirror_dx / dimension.x;
		vec2  mirt = vec2(mirx - (v_vTexcoord.x - mirx), v_vTexcoord.y);
		vec4  mirc = texture2D(gm_BaseTexture, mirt);
		
		fgC = blend(fgC, mirc);
	} 
	
	if(mirror_y == 1) {
		float miry = .5 + mirror_dy / dimension.y;
		vec2  mirt = vec2(v_vTexcoord.x, miry - (v_vTexcoord.y - miry));
		vec4  mirc = texture2D(gm_BaseTexture, mirt);
		
		fgC = blend(fgC, mirc);
	} 
	
	if(mirror_x == 1 && mirror_y == 1) {
		float mirx = .5 + mirror_dx / dimension.x;
		float miry = .5 + mirror_dy / dimension.y;
		vec2  mirt = vec2(mirx - (v_vTexcoord.x - mirx), miry - (v_vTexcoord.y - miry));
		vec4  mirc = texture2D(gm_BaseTexture, mirt);
		
		fgC = blend(fgC, mirc);
	}
	
	fgC *= color;
	
	if(layer == 1) {
		vec4 temp = bgC;
		bgC = fgC;
		fgC = temp;
	}
	
	vec4 res = bgC;
	if(selecting == 1) {
		res = blend(res, texture2D(selectSurf, v_vTexcoord));
		fgC *= texture2D(selectMask, v_vTexcoord);
	}
	
	if(erase == 1) res = vec4(res.rgb, res.a - fgC.a);
	else           res = blend(res, fgC);
	
	gl_FragColor = res;
}