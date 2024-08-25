//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PALETTE_LIMIT 1024
uniform vec4  colors[PALETTE_LIMIT];
uniform float colorAmount;
uniform float seed;

float random (in vec2 st) { return fract(sin(dot(st.xy + seed / 100., vec2(12.9898, 78.233))) * 43758.5453123); }

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = c;
	
	if(c.rgb == vec3(0.)) return;
	
	int ind = int(floor(random(gl_FragColor.xy) * colorAmount));
	gl_FragColor = colors[ind];
}
