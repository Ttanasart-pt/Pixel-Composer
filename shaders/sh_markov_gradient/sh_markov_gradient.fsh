varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform vec4 palette[256];
uniform int  paletteAmount;

uniform float seed;
uniform float threshold;

uniform vec2      matchChance;
uniform int       matchChanceUseSurf;
uniform sampler2D matchChanceSurf;

#define s3 1.7320508076

float random(in vec2 st, float seed) { return fract(sin(dot(st.xy + seed / 1000., vec2(853.98598, 78.2345543))) * 47.687523); }

void main() {
	float chn = matchChance.x;
	if(matchChanceUseSurf == 1) {
		vec4 _vMap = texture2D( matchChanceSurf, v_vTexcoord );
		chn = mix(matchChance.x, matchChance.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = col;
	
	if(random(v_vTexcoord, seed) > chn) return;
	
	for(int i = 0; i < paletteAmount - 1; i++) {
		vec4 palt = palette[i];
		
		if(distance(col.rgb, palt.rgb) <= threshold) {
			col = palette[i+1];
			break;
		}
	}
	
	gl_FragColor = col;
}