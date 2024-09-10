//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif
uniform vec4  palette[PALETTE_LIMIT];
uniform float paletteAmount;

uniform float shift;

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	
	float minDist = 999.;
	float index   = 0.;
	
	for(float i = 0.; i < paletteAmount; i++) {
		float _dist = distance(c.rgb, palette[int(i)].rgb);
		if(_dist < minDist) {
			minDist = _dist;
			index   = i;
		}
	}
	
	index = mod(index + shift, paletteAmount);
	gl_FragColor = palette[int(index)];
}
