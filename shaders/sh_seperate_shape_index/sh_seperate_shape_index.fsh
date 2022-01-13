//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(length(col.rgb * col.a) > 0.2) 
		gl_FragColor = vec4(v_vTexcoord, (col.r + col.g + col.b) / 3., 1.);
	else 
		gl_FragColor = vec4(0.);
}
