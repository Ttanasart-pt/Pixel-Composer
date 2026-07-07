varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   useMask;
uniform sampler2D mask;

uniform int   mirrorDiag;
uniform int   mirrorX;
uniform int   mirrorY;

uniform int   mirrorPosSet;
uniform vec2  mirrorPos;

vec4 blend(vec4 bg, vec4 fg) {
	float al = fg.a + bg.a * (1. - fg.a);
	if(al == 0.) return vec4(0.);
	
	vec4 res = ((fg * fg.a) + (bg * bg.a * (1. - fg.a))) / al;
	res.a = al;
	
	return res;
}

vec4 sample(vec2 px) {
	vec4 base = texture2D(gm_BaseTexture, px);
	return useMask == 0? base : base * texture2D(mask, px);
}

void main() {
	vec2 tx = 1. / dimension;
	vec4 base = sample(v_vTexcoord);
	gl_FragColor = base * v_vColour;
	
	if(mirrorX == 0 && mirrorY == 0) return;
	
	if(mirrorDiag == 0) {
		if(mirrorX == 1) {
			float sx = mirrorPos.x - (v_vTexcoord.x - mirrorPos.x);
			float sy = v_vTexcoord.y;
			
			vec4 samp = sample(vec2(sx, sy));
			base = blend(base, samp);
		}
		
		if(mirrorY == 1) {
			float sx = v_vTexcoord.x;
			float sy = mirrorPos.y - (v_vTexcoord.y - mirrorPos.y);
			
			vec4 samp = sample(vec2(sx, sy));
			base = blend(base, samp);
		}
		
		if(mirrorX == 1 && mirrorY == 1) {
			float sx = mirrorPos.x - (v_vTexcoord.x - mirrorPos.x);
			float sy = mirrorPos.y - (v_vTexcoord.y - mirrorPos.y);
			
			vec4 samp = sample(vec2(sx, sy));
			base = blend(base, samp);
		}
		
	} else {
		if(mirrorX == 1) {
			float sx = mirrorPos.x - (v_vTexcoord.y - mirrorPos.y);
			float sy = mirrorPos.y + (mirrorPos.x - v_vTexcoord.x);
			
			vec4 samp = sample(vec2(sx, sy));
			base = blend(base, samp);
		}
		
		if(mirrorY == 1) {
			float sx = mirrorPos.x + (v_vTexcoord.y - mirrorPos.y);
			float sy = mirrorPos.y + (v_vTexcoord.x - mirrorPos.x);
			
			vec4 samp = sample(vec2(sx, sy));
			base = blend(base, samp);
		}
		
		if(mirrorX == 1 && mirrorY == 1) {
			float sx = mirrorPos.x - (v_vTexcoord.y - mirrorPos.y);
			float sy = mirrorPos.y + (mirrorPos.x - v_vTexcoord.x);
			
			float rx = mirrorPos.x + (sy - mirrorPos.y);
			float ry = mirrorPos.y + (sx - mirrorPos.x);
			
			vec4 samp = sample(vec2(rx, ry));
			base = blend(base, samp);
		}
		
	}
	
	gl_FragColor = base * v_vColour;
}