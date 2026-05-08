varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  ambientColor;

uniform vec4  lightColor;
uniform float lightAngle;
uniform float contrast;
uniform float intensity;

uniform float depthBlend;
uniform float trim;

void main() {
	vec4 gem = texture2D(gm_BaseTexture, v_vTexcoord);
	float depth = gem.r;
	float angle = radians(gem.g);
	float order = gem.b;
	
	gl_FragData[1] = vec4(depth, depth, depth, gem.a);
	gl_FragData[2] = vec4(order, order, order, gem.a);
	
	if(depth == 1.) {
		gl_FragData[0] = v_vColour * (ambientColor + lightColor * intensity);
		gl_FragData[2] = vec4(1., 1., 1., gem.a);
		return;
	}
	
	if(depth < trim) {
		gl_FragData[0] = vec4(0.);
		return;
	}

	float inf = cos(angle - radians(lightAngle)) * .5 * contrast + .5;
	
	vec4 color = v_vColour;
	vec4 light = ambientColor + lightColor * inf * intensity * mix(1., depth, depthBlend);
	
	color.rgb *= light.rgb;
	color.a    = gem.a;

	gl_FragData[0] = color;
}