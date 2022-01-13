//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 samp	 = texture2D( gm_BaseTexture, v_vTexcoord );
	float bright = dot(samp.rgb, vec3(0.2126, 0.7152, 0.0722));
    gl_FragColor = v_vColour * vec4(1., 1., 1., bright);
}
