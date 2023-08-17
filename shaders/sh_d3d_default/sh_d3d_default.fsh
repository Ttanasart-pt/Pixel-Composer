//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;

varying vec3 v_worldPosition;

#region ---- light ----
	uniform vec4  light_ambient;

	#define LIGHT_DIR_LIMIT 16
	uniform int	  light_dir_count;
	uniform vec3  light_dir_direction[LIGHT_DIR_LIMIT];
	uniform vec4  light_dir_color[LIGHT_DIR_LIMIT];
	uniform float light_dir_intensity[LIGHT_DIR_LIMIT];

	#define LIGHT_PNT_LIMIT 16
	uniform int	  light_pnt_count;
	uniform vec3  light_pnt_position[LIGHT_PNT_LIMIT];
	uniform vec4  light_pnt_color[LIGHT_PNT_LIMIT];
	uniform float light_pnt_intensity[LIGHT_PNT_LIMIT];
	uniform float light_pnt_radius[LIGHT_PNT_LIMIT];
#endregion

void main() {
	vec4 final_color = texture2D( gm_BaseTexture, v_vTexcoord );
	final_color *= v_vColour;
	
	#region ++++ light ++++
		vec3 light_effect = light_ambient.rgb;
		
		for(int i = 0; i < light_dir_count; i++) {
			float light_dir_strength = dot(normalize(v_vNormal), normalize(light_dir_direction[i]));
			if(light_dir_strength < 0.)
				continue;
				
			light_dir_strength = max(light_dir_strength * light_dir_intensity[i], 0.);
			light_effect += light_dir_color[i].rgb * light_dir_strength;
		}
		
		for(int i = 0; i < light_pnt_count; i++) {
			float light_pnt_strength = dot(normalize(v_vNormal), normalize(light_pnt_position[i] - v_worldPosition));
			if(light_pnt_strength < 0.)
				continue;
			
			float light_distance     = distance(light_pnt_position[i], v_worldPosition);
			if(light_distance > light_pnt_radius[i])
				continue;
			
			float light_attenuation  = 1. - pow(light_distance / light_pnt_radius[i], 2.);
			
			light_pnt_strength = max(light_pnt_strength * light_pnt_intensity[i] * light_attenuation, 0.);
			light_effect += light_pnt_color[i].rgb * light_pnt_strength;
		}
	
		light_effect = max(light_effect, 0.);
		final_color.rgb *= light_effect;
	#endregion
	
    gl_FragColor = final_color;
}
