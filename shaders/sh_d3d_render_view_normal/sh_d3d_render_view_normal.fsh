varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int swapX;

void main() {
	vec4 viewNorm = texture2D(gm_BaseTexture, v_vTexcoord);
	
	vec3 norm = normalize(viewNorm.xyz);
	
	norm   = (norm + 1.) * .5;
	if(swapX == 1) norm.x = 1. - norm.x;
	norm.y = 1. - norm.y;
	norm.z = 1. - norm.z;
	
	gl_FragColor = vec4(norm, viewNorm.a);
}