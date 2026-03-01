varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;

varying vec4 v_worldPosition;
varying vec3 v_viewPosition;
varying vec3 v_viewNormal;

uniform vec4 color;
uniform vec2 viewRange;

void main() {
	vec2  tx   = fract(v_vTexcoord);
	vec4  base = texture2D(gm_BaseTexture, tx);
	float rim  = abs(v_viewNormal.z);
	float dep  = v_viewPosition.z;
	
	vec4  res = base * color;
	float z   = (dep - viewRange.x) / (viewRange.y - viewRange.x);
	
	gl_FragData[0] = res;
	gl_FragData[1] = vec4(vec3(z),   base.a);
	gl_FragData[2] = vec4(vec3(rim), base.a);
}