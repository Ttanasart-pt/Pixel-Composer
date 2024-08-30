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
