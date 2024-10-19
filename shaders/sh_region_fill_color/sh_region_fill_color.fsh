varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

uniform vec4  colors[PALETTE_LIMIT];
uniform int   colorAmount;
uniform float seed;

float random (in vec2 st) { return fract(sin(dot(st.xy + seed / 100., vec2(12.9898, 78.233))) * 43758.5453123); }

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = c;
	
	if(c.rgb == vec3(0.)) return;
	
	int ind = int(floor(random(gl_FragColor.xy) * float(colorAmount)));
	gl_FragColor = colors[ind];
}
