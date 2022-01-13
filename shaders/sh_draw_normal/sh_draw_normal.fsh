//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 basecolor = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 blendcolor = v_vColour;
	
	basecolor.rgb *= v_vColour.rgb;
	basecolor.a   = v_vColour.a;
	
    gl_FragColor = basecolor;
}
