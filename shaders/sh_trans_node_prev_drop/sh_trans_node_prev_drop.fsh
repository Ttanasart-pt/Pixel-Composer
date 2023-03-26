//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 position;
uniform float prog;

void main() {
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	float p  = distance(position, v_vTexcoord);
	col.a *= smoothstep(p - 0.1, p + 0.1, prog * 1.5);
	
    gl_FragColor = col;
}
