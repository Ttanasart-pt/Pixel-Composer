#pragma use(d3d_default_fragment)

#region -- d3d_default_fragment -- [1755735844.5561614]
#ifdef _YY_HLSL11_
	#extension GL_OES_standard_derivatives : enable
#endif

varying vec2  v_vTexcoord;
varying vec4  v_vColour;
varying vec3  v_vNormal;
varying vec3  v_barycentric;

varying vec4  v_worldPosition;
varying vec3  v_viewPosition;
varying vec3  v_viewNormal;
varying float v_cameraDistance;

#define PI  3.14159265359
#define TAU 6.28318530718

uniform int use_8bit; 

#region ---- light ----
	uniform vec4  light_ambient;
	uniform float shadowBias;
	
	#ifdef _YY_HLSL11_ 
		#define LIGHT_DIR_LIMIT  16
		#define LIGHT_PNT_LIMIT  16
		#define LIGHT_PNT_LIMIT6 16*6
	#else  
		#define LIGHT_DIR_LIMIT  8
		#define LIGHT_PNT_LIMIT  8
		#define LIGHT_PNT_LIMIT6 8*6
	#endif

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
	//uniform sampler2D light_dir_shadowmap_2;
	//uniform sampler2D light_dir_shadowmap_3;
	
	uniform int	  light_pnt_count;
	uniform vec3  light_pnt_position[LIGHT_PNT_LIMIT];
	uniform vec4  light_pnt_color[LIGHT_PNT_LIMIT];
	uniform float light_pnt_intensity[LIGHT_PNT_LIMIT];
	uniform float light_pnt_radius[LIGHT_PNT_LIMIT];
	
	uniform mat4  light_pnt_view[LIGHT_PNT_LIMIT6];
	uniform mat4  light_pnt_proj[LIGHT_PNT_LIMIT];
	uniform int   light_pnt_shadow_active[LIGHT_PNT_LIMIT];
	uniform float light_pnt_shadow_bias[LIGHT_DIR_LIMIT];
	uniform sampler2D light_pnt_shadowmap_0;
	uniform sampler2D light_pnt_shadowmap_1;
	//uniform sampler2D light_pnt_shadowmap_2;
	//uniform sampler2D light_pnt_shadowmap_3;
#endregion

#region ---- material ----
	vec4 mat_baseColor;
	
	uniform float mat_diffuse;
	uniform float mat_specular;
	uniform float mat_shine;
	uniform int   mat_metalic;
	uniform float mat_reflective;
	uniform vec2  mat_texScale;
	uniform vec2  mat_texShift;
	
	uniform int		  mat_defer_normal;
	uniform float	  mat_normal_strength;
	uniform sampler2D mat_normal_map;
	
	uniform int		  mat_flip;
#endregion

#region ---- rendering ----
	uniform vec3 cameraPosition;
	uniform int  gammaCorrection;
	
	uniform int       env_use_mapping;
	uniform sampler2D env_map;
	uniform vec2      env_map_dimension;
	
	uniform mat4 viewProjMat;
	
	uniform int   show_wireframe;
	uniform int   wireframe_aa;
	uniform int   wireframe_shade;
	uniform int   wireframe_only;
	uniform float wireframe_width;
	uniform vec4  wireframe_color;
	
	uniform vec4  backface_blending;
#endregion

#region ++++ mapping ++++
	vec2 equirectangularUv(vec3 dir) {
		vec3 n = normalize(dir);
		return vec2((atan(n.x, n.y) / TAU) + 0.5, 1. - acos(n.z) / PI);
	}
	
	float unormToFloat(vec3 v) { 
		v *= 256.;
		return (v.r * 65536. + v.g * 256. + v.b) / (65536.); 
	}
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
		vec4 d;
		
		       if(index == 0) d = texture2D(light_dir_shadowmap_0, position);
		  else if(index == 1) d = texture2D(light_dir_shadowmap_1, position);
		//else if(index == 2) d = texture2D(light_dir_shadowmap_2, position);
		//else if(index == 3) d = texture2D(light_dir_shadowmap_3, position);
		
		if(use_8bit == 1) return unormToFloat(d.rgb);
		return d.r;
	}

	float samplePntShadowMap(int index, vec2 position, int side) {
		// -x, x, -y, y, -z, z
		// r0, b0, g0, r1, g1, b1
			
		float d = 0.;
		
		position.x /= 2.;
		if(side >= 3) {
			position.x += 0.5;
			side -= 3;
		}
	
		       if(index == 0) d = texture2D(light_pnt_shadowmap_0, position)[side];
		  else if(index == 1) d = texture2D(light_pnt_shadowmap_1, position)[side];
		//else if(index == 2) d = texture2D(light_pnt_shadowmap_2, position)[side];
		//else if(index == 3) d = texture2D(light_pnt_shadowmap_3, position)[side];
		
		return d;
	}
#endregion

#region ++++ Phong shading ++++
	vec3 phongLight(vec3 normal, vec3 lightVec, vec3 viewVec, vec3 light) {
		vec3 lightDir = normalize(lightVec);
		vec3 viewDir  = normalize(viewVec);
		vec3 refcDir  = reflect(-lightDir, normal);
		
		float kD = 1., kS = 0.;
		
		if(mat_diffuse + mat_specular != 0.) {
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

vec4 wireframeCalc(in vec4 baseColr) {
	vec3  bc_width    = fwidth(v_barycentric);
	vec3  baryWidth   = bc_width * wireframe_width;
	
	vec3  aa_width    = wireframe_aa == 1? smoothstep(baryWidth * .9, baryWidth, v_barycentric) : 
	                                       step(baryWidth, v_barycentric);
	                                       
	float edge_factor = 1. - min(aa_width.r, min(aa_width.g, aa_width.b));
	vec4  baseColor   = wireframe_only == 1? vec4(0.) : baseColr;
	vec4  mixed_color = mix(baseColor, wireframe_color, edge_factor * wireframe_color.a);
	
	mixed_color.a *= baseColr.a;
	return mixed_color;
}

float normalCurvature(vec3 n) {
      vec3 dx = dFdx(n);
	  vec3 dy = dFdy(n);
	  vec3 xneg = n - dx;
	  vec3 xpos = n + dx;
	  vec3 yneg = n - dy;
	  vec3 ypos = n + dy;
	  float curvature = (cross(xneg, xpos).y - cross(yneg, ypos).x) * 4.0;
	  return curvature;
}

void main() {
	vec2 uv_coord = v_vTexcoord;
	if(mat_flip == 1) uv_coord.y = -uv_coord.y;
	
	uv_coord           = fract(uv_coord * mat_texScale + mat_texShift);
	mat_baseColor      = texture2D( gm_BaseTexture, uv_coord );
	mat_baseColor     *= v_vColour;
	
	vec4 final_color   = mat_baseColor;
	vec3 shadow        = vec3(0.);
	if(show_wireframe == 1 && wireframe_shade == 1) final_color = wireframeCalc(final_color);
	
	vec3 viewDirection = normalize(cameraPosition - v_worldPosition.xyz);
	
	vec4 viewProjPos   = viewProjMat * vec4(v_worldPosition.xyz, 1.);
		 viewProjPos  /= viewProjPos.w;
		 viewProjPos   = viewProjPos * 0.5 + 0.5;
		
	vec3 normal        = mat_defer_normal == 1? texture2D(mat_normal_map, viewProjPos.xy).rgb : v_vNormal;
		 normal        = normalize(normal);
	bool isBackface    = dot(normal, viewDirection) < 0.0;
	
	#region ++++ base color effect ++++
		if(isBackface) final_color *= backface_blending;
	#endregion
	
	#region ++++ cavity ++++
		vec3  dd = fwidth(normal);
		float cavity = dot(dd, dd);
		cavity = smoothstep(0., .000001, cavity);
	#endregion
	
	#region ++++ environment ++++
		if(env_use_mapping == 1 && mat_reflective > 0.) {
			
			vec3  reflectDir         = reflect(viewDirection, normal);
			float refRad             = mix(16., 0., mat_reflective);
			vec2  tx                 = 1. / env_map_dimension;
			vec2  reflect_sample_pos = equirectangularUv(reflectDir);
			vec4  env_sampled        = vec4(0.);
			float weight             = 0.;
			
			for(float i = -refRad; i <= refRad; i++)
			for(float j = -refRad; j <= refRad; j++) {
				vec2 _map_pos = reflect_sample_pos + vec2(i, j) * tx;
				
					 if(_map_pos.y < 0.) _map_pos.y = -_map_pos.y;
				else if(_map_pos.y > 1.) _map_pos.y = 1. - (_map_pos.y - 1.);
				
				vec4 _samp   = texture2D(env_map, _map_pos);
				env_sampled += _samp;
				weight      += _samp.a;
			}
			
			env_sampled  /= weight;
			env_sampled.a = 1.;
			
			vec4 env_effect = mat_metalic == 1? env_sampled * final_color : env_sampled;
				 env_effect = 1. - ( mat_reflective * ( 1. - env_effect ));
			
			final_color *= env_effect;
		}
	#endregion
	
	#region ++++ light ++++
		int   shadow_map_index = 0;
		vec3  light_effect     = light_ambient.rgb;
		float val = 0.;
		
		#region ++++ directional ++++
			float light_map_depth;
			float lightDistance;
			float shadow_culled;
		
			shadow_map_index = 0;
			for(int i = 0; i < light_dir_count; i++) {
				vec3 lightVector   = normalize(light_dir_direction[i]);
				
				if(light_dir_shadow_active[i] == 1) { //use shadow
					vec4  l_cameraSpace   = light_dir_view[i] * v_worldPosition;
					vec4  l_screenSpace   = light_dir_proj[i] * l_cameraSpace;
					float l_lightDistance = l_screenSpace.z;
					vec2  lightMapUV      = (l_screenSpace.xy / l_screenSpace.w * 0.5) + 0.5;
					
					if(lightMapUV.x >= 0. && lightMapUV.x <= 1. && lightMapUV.y >= 0. && lightMapUV.y <= 1.) {
						light_map_depth = sampleDirShadowMap(shadow_map_index, lightMapUV);
						
						shadow_map_index++;
						float shadowFactor = dot(normal, lightVector);
						float bias = mix(light_dir_shadow_bias[i], 0., shadowFactor);
						
						if(l_lightDistance > light_map_depth + bias) {
							shadow += 1. / float(light_dir_count + light_pnt_count);
							continue;
						}
					}
				}
				
				vec3 light_phong = phongLight(normal, lightVector, viewDirection, light_dir_color[i].rgb);
				light_effect += light_phong * light_dir_intensity[i];
			}
		#endregion
		
		#region ++++ point ++++
			float light_distance;
			float light_attenuation;
		
			shadow_map_index = 0;
			for(int i = 0; i < light_pnt_count; i++) {
				vec3 lightVector   = light_pnt_position[i] - v_worldPosition.xyz;
				
				light_distance = length(lightVector);
				if(light_distance > light_pnt_radius[i])
					continue;
				
				lightVector = normalize(lightVector);
				
				if(light_pnt_shadow_active[i] == 1) { //use shadow
					vec3 dirAbs = abs(lightVector);
					int side    = dirAbs.x > dirAbs.y ? (dirAbs.x > dirAbs.z ? 0 : 2) : (dirAbs.y > dirAbs.z ? 1 : 2);
					side *= 2;
					     if(side == 0 && lightVector.x > 0.) side += 1;
					else if(side == 2 && lightVector.y > 0.) side += 1;
					else if(side == 4 && lightVector.z > 0.) side += 1;
					
					vec4  l_cameraSpace   = light_pnt_view[i * 6 + side] * v_worldPosition;
					vec4  l_screenSpace   = light_pnt_proj[i] * l_cameraSpace;
					float l_lightDistance = l_screenSpace.z;
					vec2  lightMapUV      = (l_screenSpace.xy / l_screenSpace.w * 0.5) + 0.5;
					
					if(lightMapUV.x >= 0. && lightMapUV.x <= 1. && lightMapUV.y >= 0. && lightMapUV.y <= 1.) {
						
						float shadowFactor = dot(normal, lightVector);
						float bias = mix(light_pnt_shadow_bias[i], 0., shadowFactor);
					
						light_map_depth = samplePntShadowMap(shadow_map_index, lightMapUV, side);
						shadow_map_index++;
						
						if(l_lightDistance > light_map_depth + bias) {
							shadow += 1. / float(light_dir_count + light_pnt_count);
							continue;
						}
					}
				} 
				
				light_attenuation = 1. - pow(light_distance / light_pnt_radius[i], 2.);
				vec3 light_phong = phongLight(normal, lightVector, viewDirection, light_pnt_color[i].rgb * light_attenuation);
				light_effect += light_phong * light_pnt_intensity[i];
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
	
	if(show_wireframe == 1 && wireframe_shade == 0) final_color = wireframeCalc(final_color);
	if(final_color.a < 0.1) discard;
	
	gl_FragData[0] = final_color;
	gl_FragData[1] = vec4(0.5 + normal * 0.5, final_color.a);
	gl_FragData[2] = vec4(vec3(1. - abs(v_cameraDistance)), final_color.a);
	gl_FragData[3] = vec4(shadow, 1.);
}
#endregion -- d3d_default_fragment --
#pragma use(d3d_default_fragment)