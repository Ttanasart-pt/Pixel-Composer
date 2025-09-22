varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

uniform sampler2D glowMask;
uniform vec4  palette[PALETTE_LIMIT];
uniform int   keys;

float colorDifferentRGB(in vec4 c1, in vec4 c2) {
	return length(c1.rgb - c2.rgb);
}

void main() {
	vec4  _col = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4  _msk = texture2D( glowMask, v_vTexcoord );
	float _mms = (_msk.r + _msk.g + _msk.b) / 3.;
	if(_mms > 0.) {
		gl_FragColor = _col;
		return;
	}
	
	vec4  col = _col;
	int   closet_index = 0;
	float closet_value = 999.;
	
	for(int i = 0; i < keys; i++) {
		vec4  pcol = palette[i];
		float dif  = colorDifferentRGB(pcol, col);
		
		if(dif < closet_value) {
			closet_value = dif;
			closet_index = i;
		}
	}
	
    gl_FragColor = palette[closet_index];
	gl_FragColor.a = _col.a;
}
