//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_worldPosition;

#define PI  3.14159265359
#define TAU 6.28318530718

uniform vec4	  light_ambient;
uniform vec3	  cameraPosition;
uniform int       env_use_mapping;
uniform sampler2D env_map;
uniform vec2      env_map_dimension;

vec2 equirectangularUv(vec3 dir) {
	vec3 n = normalize(dir);
	return vec2((atan(n.x, n.y) / TAU) + 0.5, 1. - acos(n.z) / PI);
}
	
void main() {
	if(env_use_mapping == 1) {
		vec3  viewDirection = normalize(cameraPosition - v_worldPosition.xyz);
		vec2  viewSample    = equirectangularUv(viewDirection);
		gl_FragColor = light_ambient * texture2D(env_map, viewSample);
	} else 
		gl_FragColor = light_ambient;
}
