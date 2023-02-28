//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 color;
uniform float thres;

void main() {
    vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	float n = step(distance(col, color), thres);
	gl_FragColor = vec4(vec3(n), 1.);
}
