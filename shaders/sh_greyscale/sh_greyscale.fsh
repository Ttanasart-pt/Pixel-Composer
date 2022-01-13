//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float brightness;
uniform float contrast;

void main() {
    vec4 col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 col_b = col + vec4(brightness, brightness, brightness, 0.0);
	vec4 col_bc = vec4(col_b.rgb * contrast, col_b.a);
	
	col_bc.rgb = vec3(dot(col_bc.rgb, vec3(0.2126, 0.7152, 0.0722)));
	
	gl_FragColor = col_bc;
}
