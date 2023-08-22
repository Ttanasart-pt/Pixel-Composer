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
