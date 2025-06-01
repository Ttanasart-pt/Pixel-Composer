varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D flowMask;
uniform vec2  dimension;

uniform float flowTime;
uniform float flowRate;
uniform float flowSpeed;
uniform float flowSample;

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 flowMap = texture2D(flowMask, v_vTexcoord);
	
	float ft    = fract(flowTime * flowSpeed);
	vec2  dx    = -flowMap.xy * tx * flowRate * flowSample;
	vec2  flow0 = fract(v_vTexcoord + dx * (ft     ));
	vec2  flow1 = fract(v_vTexcoord + dx * (ft - 1.));
	
	vec4 c0 = texture2D(gm_BaseTexture, flow0);
	vec4 c1 = texture2D(gm_BaseTexture, flow1);
	
	ft = smoothstep(0., 1., ft);
	gl_FragColor = mix(c0, c1, ft);
}