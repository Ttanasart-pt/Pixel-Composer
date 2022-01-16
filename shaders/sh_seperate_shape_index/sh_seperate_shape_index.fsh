//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(length(col.rgb * col.a) > 0.2) 
		gl_FragColor = vec4(v_vTexcoord.x, v_vTexcoord.y, v_vTexcoord.x, v_vTexcoord.y);
	else 
		gl_FragColor = vec4(0.);
}
