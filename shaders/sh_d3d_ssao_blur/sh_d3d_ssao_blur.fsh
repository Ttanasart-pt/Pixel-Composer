varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D vNormal;
uniform float radius;
uniform vec2  dimension;

void main() {
	vec3 cNormal = texture2D( vNormal, v_vTexcoord ).rgb;
	vec2 tx = 1. / dimension;
	
	vec3  sampled = vec3(0.);
	float weight = 0.;
	
	for(float i = -radius; i <= radius; i++)
	for(float j = -radius; j <= radius; j++) {
		vec2 pos = v_vTexcoord + vec2(i, j) * tx;
		if(pos.x < 0. || pos.y < 0. || pos.x > 1. || pos.y > 1.)
			continue;
		
		float str = 1. - length(vec2(i, j)) / radius;
		if(str < 0.) continue;
		
		vec3 _normal = texture2D( vNormal, pos ).rgb;
		if(distance(_normal, cNormal) > 0.2) continue;
		
		sampled += texture2D( gm_BaseTexture, pos ).rgb * str;
		weight  += str;
	}
	
    gl_FragColor = vec4(sampled / weight, 1.);
}
