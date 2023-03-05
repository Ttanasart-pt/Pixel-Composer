//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 color;

void main() {
	vec4 samp	 = texture2D( gm_BaseTexture, v_vTexcoord );
	float bright = dot(samp.rgb, vec3(0.2126, 0.7152, 0.0722));
	vec4 col	 = v_vColour * color;
	col.a *= bright;
	
    gl_FragColor = col;
}
