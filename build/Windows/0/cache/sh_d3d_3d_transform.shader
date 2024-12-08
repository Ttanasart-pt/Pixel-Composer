attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2  v_vTexcoord;
varying float v_LightDepth;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
	v_LightDepth = gl_Position.z / gl_Position.w;
	v_vTexcoord  = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2  v_vTexcoord;
varying float v_LightDepth;

uniform vec2  viewPlane;
uniform vec2  tiling;

void main() {
	vec2 uv_coord = fract(v_vTexcoord * tiling);
	vec4 mat_baseColor = texture2D( gm_BaseTexture, uv_coord );
	
	float depth = (v_LightDepth - viewPlane.x) / (viewPlane.y - viewPlane.x);
	depth = 1. - depth;
	
	gl_FragData[0] = mat_baseColor;
	gl_FragData[1] = vec4(vec3(depth), 1.);
}

