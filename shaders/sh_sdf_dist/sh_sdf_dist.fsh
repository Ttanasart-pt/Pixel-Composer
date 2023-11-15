//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int side;
uniform float max_distance;

void main() {
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	if(col.xy == vec2(0.)) {
		gl_FragColor = vec4(vec3(0.), 1.);
		return;
	}
	
	float dist = (max_distance - distance(col.xy, v_vTexcoord)) / max_distance;
	
	if((side == 0 && col.z == 0.) || (side == 1 && col.z == 1.)) {
		gl_FragColor = vec4(vec3(col.z), 1.);
		return;
	}
	
    gl_FragColor = vec4(vec3(dist), 1.);
}
