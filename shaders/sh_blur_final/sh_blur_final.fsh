//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D alpha_mask;

void main() {
	vec4 alpha = texture2D( alpha_mask, v_vTexcoord );
    gl_FragColor = vec4(texture2D( gm_BaseTexture, v_vTexcoord ).rgb, alpha);
	gl_FragColor = vec4(vec3(1.), alpha);
}
