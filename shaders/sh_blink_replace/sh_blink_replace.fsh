varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;
uniform float ratio;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

uniform int  usePalette;
uniform vec4 palette[PALETTE_LIMIT];
uniform int  paletteAmount;

float random (in vec2 st) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * (43758.5453123 + seed)); }

void main() {
	vec4 pos = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = vec4(0.);
	if(pos.z == 0. || pos.a == 0.) return;
	
    int   index = int(floor(random(pos.rg) * float(paletteAmount)));
    float rrat  = random(pos.rg + vec2(1.6193, 3.5341));
	if(rrat >= ratio) return; 
	
	gl_FragColor = palette[index];
}
