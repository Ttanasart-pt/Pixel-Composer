varying vec4 v_worldPosition;
varying vec3 v_viewPosition;
varying vec3 v_vNormal;

void main() {
	gl_FragData[0] = vec4(v_worldPosition.xyz, 1.);
	gl_FragData[1] = vec4(v_viewPosition, 1.);
	gl_FragData[2] = vec4(v_vNormal, 1.);
}
