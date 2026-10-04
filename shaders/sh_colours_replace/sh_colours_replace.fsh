#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int   useMask;
uniform sampler2D mask;

uniform vec4 colorFrom[PALETTE_LIMIT];
uniform int  colorFromAmount;

uniform vec4 colorTo[PALETTE_LIMIT];
uniform int  colorToAmount;

uniform float threshold;
uniform int   alpha;
uniform int   multiplyOrig;

void main() {
	vec4 p = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = p;
	
	int   index   = 0;
	float minDist = 999.;
	
	for(int i = 0; i < colorFromAmount; i++ ) {
		vec4 c = colorFrom[i];
		float dist = alpha == 1? distance(p.rgb * p.a, c.rgb * c.a) : distance(p.rgb, c.rgb);
		
		if(dist < minDist) {
			minDist = dist;
			index   = i;
		}
	}
	
	if(minDist <= threshold)
    	gl_FragColor = vec4(colorTo[index].rgb, (multiplyOrig == 1? p.a : 1.) * colorTo[index].a) * v_vColour;
	
}
