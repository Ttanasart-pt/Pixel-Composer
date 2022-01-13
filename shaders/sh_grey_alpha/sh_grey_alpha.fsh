//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float brightness;
uniform float contrast;

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722))  * col.a;
}

void main() {
    vec4 col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = vec4(vec3(1.), bright(col));
}
