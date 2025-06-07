#ifdef _YY_HLSL11_
	#extension GL_OES_standard_derivatives : enable
#endif

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_barycentric;

varying vec4  v_worldPosition;
varying vec3  v_viewPosition;
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
#endregion

void main() {
	vec2 uv_coord = v_vTexcoord;
	if(mat_flip == 1) uv_coord.y = -uv_coord.y;
	
	uv_coord           = fract(uv_coord * mat_texScale + mat_texShift);
	mat_baseColor      = texture2D( gm_BaseTexture, uv_coord );
	mat_baseColor     *= v_vColour;
	
	gl_FragData[0] = mat_baseColor;
	// gl_FragColor = mat_baseColor;
}