//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int replace;
uniform vec4 color;

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722))  * col.a;
}

void main() {
    vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	if(replace == 0) gl_FragColor = vec4(col.rgb, bright(col));
	else			 gl_FragColor = vec4(color.rgb, bright(col));
}
