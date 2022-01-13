//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float black;
uniform float white;

void main() {
	vec4 col  = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	col.r = (col.r - black) / (white - black);
	col.g = (col.g - black) / (white - black);
	col.b = (col.b - black) / (white - black);
	
    gl_FragColor = col;
}
