// PC3D rendering shader
//   - BRDF By Xpanda and OGLDEV

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;

varying vec4  v_worldPosition;
varying vec3  v_viewPosition;
varying float v_cameraDistance;

#define PI  3.14159265359
#define TAU 6.28318530718

#region ---- light ----
	uniform vec4  light_ambient;
	uniform float shadowBias;
	
	#define LIGHT_DIR_LIMIT 16
	uniform int	  light_dir_count;
	uniform vec3  light_dir_direction[LIGHT_DIR_LIMIT];
	uniform vec4  light_dir_color[LIGHT_DIR_LIMIT];
	uniform float light_dir_intensity[LIGHT_DIR_LIMIT];
	
	uniform mat4  light_dir_view[LIGHT_DIR_LIMIT];
	uniform mat4  light_dir_proj[LIGHT_DIR_LIMIT];
	uniform int   light_dir_shadow_active[LIGHT_DIR_LIMIT];
	uniform float light_dir_shadow_bias[LIGHT_DIR_LIMIT];
	uniform sampler2D light_dir_shadowmap_0;
	uniform sampler2D light_dir_shadowmap_1;
	uniform sampler2D light_dir_shadowmap_2;
	uniform sampler2D light_dir_shadowmap_3;
	
	#define LIGHT_PNT_LIMIT 16
	uniform int	  light_pnt_count;
	uniform vec3  light_pnt_position[LIGHT_PNT_LIMIT];
	uniform vec4  light_pnt_color[LIGHT_PNT_LIMIT];
	uniform float light_pnt_intensity[LIGHT_PNT_LIMIT];
	uniform float light_pnt_radius[LIGHT_PNT_LIMIT];
	
	uniform mat4  light_pnt_view[96];
	uniform mat4  light_pnt_proj[LIGHT_PNT_LIMIT];
	uniform int   light_pnt_shadow_active[LIGHT_PNT_LIMIT];
	uniform float light_pnt_shadow_bias[LIGHT_DIR_LIMIT];
	uniform sampler2D light_pnt_shadowmap_0;
	uniform sampler2D light_pnt_shadowmap_1;
	uniform sampler2D light_pnt_shadowmap_2;
	uniform sampler2D light_pnt_shadowmap_3;
	uniform sampler2D light_pnt_shadowmap_4;
	uniform sampler2D light_pnt_shadowmap_5;
	uniform sampler2D light_pnt_shadowmap_6;
	uniform sampler2D light_pnt_shadowmap_7;
#endregion

#region ---- material ----
	vec4 mat_baseColor;
	
	uniform float mat_diffuse;
	uniform float mat_specular;
	uniform float mat_shine;
	uniform int   mat_metalic;
#endregion

#region ---- rendering ----
	uniform vec3 cameraPosition;
	uniform int  gammaCorrection;
#endregion

#region ++++ matrix ++++
	float matrixGet(mat4 matrix, int index) { 
		if(index < 0 || index > 15) return 0.;
		
		int _x = int(floor(float(index) / 4.));
		int _y = int(mod(float(index), 4.));
		return matrix[_x][_y]; 
	}

	mat4 matrixSet(mat4 matrix, int index, float value) { 
		if(index < 0 || index > 15) return matrix;
		
		int _x = int(floor(float(index) / 4.));
		int _y = int(mod(float(index), 4.));
		matrix[_x][_y] = value; 
		return matrix;
	}
#endregion

#region ++++ shadow sampler ++++
	float sampleDirShadowMap(int index, vec2 position) {
		if(index == 0) return texture2D(light_dir_shadowmap_0, position).r;
		if(index == 1) return texture2D(light_dir_shadowmap_1, position).r;
		if(index == 2) return texture2D(light_dir_shadowmap_2, position).r;
		if(index == 3) return texture2D(light_dir_shadowmap_3, position).r;
		return 0.;
	}

	float samplePntShadowMap(int index, vec2 position, int side) {
		position.x /= 2.;
		if(side >= 3) {
			position.x += 0.5;
			side -= 3;
		}
	
		if(index == 0) return texture2D(light_pnt_shadowmap_0, position)[side];
		if(index == 1) return texture2D(light_pnt_shadowmap_1, position)[side];
		if(index == 2) return texture2D(light_pnt_shadowmap_2, position)[side];
		if(index == 3) return texture2D(light_pnt_shadowmap_3, position)[side];
		return 0.;
	}
#endregion

#region ++++ Phong shading ++++
	vec3 phongLight(vec3 normal, vec3 lightVec, vec3 viewVec, vec3 light) {
		vec3 lightDir = normalize(lightVec);
		vec3 viewDir  = normalize(viewVec);
		vec3 refcDir  = reflect(-lightDir, normal);
		
		float kD = 1, kS = 0;
		
		if(mat_diffuse + mat_specular != 0) {
			kD = mat_diffuse  / (mat_diffuse + mat_specular);
			kS = mat_specular / (mat_diffuse + mat_specular);
		}
		
		vec3  lLambert = max(0., dot(normal, lightDir)) * light;
		
		float specular  = pow(max(dot(viewDir, refcDir), 0.), max(0.001, mat_shine));
		vec3  lSpecular = specular * light;
		if(mat_metalic == 1) lSpecular *= mat_baseColor.rgb;
		
		return kD * lLambert + kS * lSpecular;
	}
#endregion

void main() {
	mat_baseColor = texture2D( gm_BaseTexture, v_vTexcoord );
	mat_baseColor *= v_vColour;
	
	vec4 final_color   = mat_baseColor;
	vec3 normal        = normalize(v_vNormal);
	vec3 viewDirection = normalize(cameraPosition - v_worldPosition.xyz);
	
	gl_FragData[0] = vec4(0.);
	gl_FragData[1] = vec4(0.);
	gl_FragData[2] = vec4(0.);
	
	#region ++++ light ++++
		int shadow_map_index = 0;
		vec3 light_effect = light_ambient.rgb;
		float val = 0.;
		
		#region ++++ directional ++++
			float light_dir_strength;
			float light_map_depth;
			float lightDistance;
			float shadow_culled;
		
			shadow_map_index = 0;
			for(int i = 0; i < light_dir_count; i++) {
				vec3 lightVector   = normalize(light_dir_direction[i]);
				//light_dir_strength = dot(normal, lightVector);
				//if(light_dir_strength < 0.)
				//	continue;
			
				if(light_dir_shadow_active[i] == 1) {
					vec4 cameraSpace = light_dir_view[i] * v_worldPosition;
					vec4 screenSpace = light_dir_proj[i] * cameraSpace;
	
					float v_lightDistance = screenSpace.z / screenSpace.w;
					vec2 lightMapPosition = (screenSpace.xy / screenSpace.w * 0.5) + 0.5;
				
					light_map_depth = sampleDirShadowMap(shadow_map_index, lightMapPosition);
					shadow_map_index++;
					lightDistance = v_lightDistance;
					float shadowFactor = dot(normal, lightVector);
					float bias = mix(light_dir_shadow_bias[i], 0., shadowFactor);
					
					if(lightDistance > light_map_depth + bias)
						continue;
				} 
				
				//light_dir_strength = max(light_dir_strength * light_dir_intensity[i], 0.);
				vec3 light_phong = phongLight(normal, lightVector, viewDirection, light_dir_color[i].rgb);
				
				light_effect += light_phong;
			}
		#endregion
		
		#region ++++ point ++++
			float light_pnt_strength;
			float light_distance;
			float light_attenuation;
		
			shadow_map_index = 0;
			for(int i = 0; i < light_pnt_count; i++) {
				vec3 lightVector   = normalize(light_pnt_position[i] - v_worldPosition.xyz);
				//light_pnt_strength = dot(normal, lightVector);
				//if(light_pnt_strength < 0.)
				//	continue;
			
				light_distance = length(lightVector);
				if(light_distance > light_pnt_radius[i])
					continue;
			
				if(light_pnt_shadow_active[i] == 1) {
					vec3 dirAbs = abs(lightVector);
					int side    = dirAbs.x > dirAbs.y ?
								  (dirAbs.x > dirAbs.z ? 0 : 2) :
								  (dirAbs.y > dirAbs.z ? 1 : 2);
					side *= 2;
					if(side == 0 && lightVector.x < 0.)	     side += 1;
					else if(side == 2 && lightVector.y < 0.) side += 1;
					else if(side == 4 && lightVector.z < 0.) side += 1;
					
					vec4 cameraSpace = light_pnt_view[i * 6 + side] * v_worldPosition;
					vec4 screenSpace = light_pnt_proj[i] * cameraSpace;
					float v_lightDistance = screenSpace.z / screenSpace.w;
					vec2 lightMapPosition = (screenSpace.xy / screenSpace.w * 0.5) + 0.5;
					float shadowFactor = dot(normal, lightVector);
					float bias = mix(light_pnt_shadow_bias[i], 0., shadowFactor);
					
					light_map_depth = samplePntShadowMap(shadow_map_index, lightMapPosition, side);
					shadow_map_index++;
					
					if(v_lightDistance > light_map_depth + bias)
						continue;
				} 
				
				light_attenuation = 1. - pow(light_distance / light_pnt_radius[i], 2.);
			
				//light_pnt_strength = max(light_pnt_strength * light_pnt_intensity[i] * light_attenuation, 0.);
				vec3 light_phong = phongLight(normal, lightVector, viewDirection, light_pnt_color[i].rgb * light_attenuation);
				
				light_effect += light_phong;
			}
		#endregion
	
		light_effect = max(light_effect, 0.);
		
		if(gammaCorrection == 1) {
			light_effect.r = pow(light_effect.r, 1. / 2.2);
			light_effect.g = pow(light_effect.g, 1. / 2.2);
			light_effect.b = pow(light_effect.b, 1. / 2.2);
		}
		
		final_color.rgb *= light_effect;
	#endregion
	
	gl_FragData[0] = final_color;
	gl_FragData[1] = vec4(0.5 + normal * 0.5, 1.);
	gl_FragData[2]  = vec4(vec3(v_cameraDistance), 1.);
}
