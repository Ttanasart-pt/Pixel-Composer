//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 center;
uniform float strength;

void main() {
	vec2 texel = 1.0 / dimension;
    vec2 coords = (v_vTexcoord - center / dimension) * 2.0;
    float coordDot = dot(coords, coords);
    
    vec2 precompute = strength * coordDot * coords;
    vec2 uvR = v_vTexcoord - texel.xy * precompute;
    vec2 uvB = v_vTexcoord + texel.xy * precompute;
    
    vec4 color;
    color.r = texture2D(gm_BaseTexture, uvR).r;
    color.g = texture2D(gm_BaseTexture, v_vTexcoord).g;
    color.b = texture2D(gm_BaseTexture, uvB).b;
    color.a = texture2D(gm_BaseTexture, v_vTexcoord).a + 
			  texture2D(gm_BaseTexture, uvR).a + 
			  texture2D(gm_BaseTexture, uvB).a;
	
	gl_FragColor = color;
}
