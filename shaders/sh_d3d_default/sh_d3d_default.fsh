//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;

varying vec3 v_worldPosition;

uniform vec4  light_ambient;
uniform vec3  light_dir_direction;
uniform vec4  light_dir_color;
uniform float light_dir_intensity;

void main() {
	vec4 final_color = texture2D( gm_BaseTexture, v_vTexcoord );
	final_color *= v_vColour;
	
	///////////////// LIGHT ///////////////// 
	
	vec3 light_effect = light_ambient.rgb * light_ambient.a;
	
	float light_dir_strength = dot(normalize(v_vNormal), normalize(light_dir_direction));
	light_dir_strength = max(light_dir_strength * light_dir_intensity, 0.);
	light_effect += light_dir_color.rgb * light_dir_color.a * light_dir_strength;
	
	light_effect = max(light_effect, 0.);
	final_color.rgb *= light_effect;
	
	///////////////// FINAL ///////////////// 
	
    gl_FragColor = final_color;
}
