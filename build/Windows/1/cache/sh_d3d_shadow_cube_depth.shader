attribute vec3 in_Position;      
attribute vec3 in_Normal;        
attribute vec4 in_Colour;        
attribute vec2 in_TextureCoord;  

varying vec2 v_vTexcoord;
varying float v_LightDepth_0;
varying float v_LightDepth_1;
varying float v_LightDepth_2;
varying float v_LightDepth_3;
varying float v_LightDepth_4;
varying float v_LightDepth_5;

uniform mat4 viewMat[6];
uniform mat4 projMat;

void main() {
    v_vTexcoord = in_TextureCoord;
	
    vec4 object_space_pos = vec4( in_Position, 1.0);
    gl_Position = vec4(0., 0., 1., 1.);
	
	vec4 worldPos = gm_Matrices[MATRIX_WORLD] * object_space_pos;
	
	vec4 proj0 = projMat * (viewMat[0] * object_space_pos);
	v_LightDepth_0 = proj0.z / proj0.w;
	
	vec4 proj1 = projMat * (viewMat[1] * object_space_pos);
	v_LightDepth_1 = proj1.z / proj1.w;
	
	vec4 proj2 = projMat * (viewMat[2] * object_space_pos);
	v_LightDepth_2 = proj2.z / proj2.w;
	
	vec4 proj3 = projMat * (viewMat[3] * object_space_pos);
	v_LightDepth_3 = proj3.z / proj3.w;
	
	vec4 proj4 = projMat * (viewMat[4] * object_space_pos);
	v_LightDepth_4 = proj4.z / proj4.w;
	
	vec4 proj5 = projMat * (viewMat[5] * object_space_pos);
	v_LightDepth_5 = proj5.z / proj5.w;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;

varying float v_LightDepth_0;
varying float v_LightDepth_1;
varying float v_LightDepth_2;
varying float v_LightDepth_3;
varying float v_LightDepth_4;
varying float v_LightDepth_5;

void main() {
	gl_FragData[0] = vec4(v_LightDepth_0, v_LightDepth_1, v_LightDepth_2, 1.);
	gl_FragData[1] = vec4(v_LightDepth_3, v_LightDepth_4, v_LightDepth_5, 1.);
}

