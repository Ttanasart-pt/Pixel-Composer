attribute vec3 in_Position;      
attribute vec3 in_Normal;        
attribute vec4 in_Colour;        
attribute vec2 in_TextureCoord;  

varying float v_LightDepth;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
	v_LightDepth = gl_Position.z;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying float v_LightDepth;
uniform int   use_8bit;

vec3 floatToUnorm(float v) { 
	v *= 65536.;
	
	float r = floor(v / 65536.); v -= 65536. * r;
	float g = floor(v /   256.); v -=   256. * g;
	float b = floor(v);
	
	return vec3(r, g, b) / 256.; 
}
	
void main() {
	float d = v_LightDepth;
	
	if(use_8bit == 1) gl_FragColor = vec4(floatToUnorm(d), 1.);
	else              gl_FragColor = vec4(d, 0., 0., 1.);
}

