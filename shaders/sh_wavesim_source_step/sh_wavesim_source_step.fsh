varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D domain;
uniform vec2  dimension;

uniform float damping;
uniform float edgeWidth;
uniform float edgeStrength;
uniform float k;

uniform int   boundary;

float sampleHeight(vec2 pos, float h) { 
	if(pos.x < 0. || pos.y < 0. || pos.x >= 1. || pos.y >= 1.) {
		if(boundary == 0) // free
			pos = clamp(pos, 0., 1.);
		
		else if(boundary == 1) // wall
			return h;
			
		else if(boundary == 2) // wrap
			pos = fract(pos);
	}
	
	vec4 s = texture2D(domain, pos);
    if(s.b > 0.5) return h;
    return s.r;
}

void main() {
	vec2  tx  = 1. / dimension;
	
	vec4  c  = texture2D(domain, v_vTexcoord);
	if(c.b > 0.5) { // solid
		gl_FragColor = vec4(0., 0., 1., 1.); 
		return; 
	}

	float h  = c.r;
	float hp = c.g;
	
	float lap = sampleHeight(v_vTexcoord + vec2( tx.x, 0), h)
	          + sampleHeight(v_vTexcoord + vec2(-tx.x, 0), h)
	          + sampleHeight(v_vTexcoord + vec2(0,  tx.y), h)
	          + sampleHeight(v_vTexcoord + vec2(0, -tx.y), h)
	          - 4. * h;
    
	float d = damping;
	if(boundary == 0) {
		float edge = min(min(v_vTexcoord.x, 1.-v_vTexcoord.x), min(v_vTexcoord.y, 1.-v_vTexcoord.y));
		float t    = 1. - smoothstep(0., edgeWidth, edge);
		d = damping * (1. - edgeStrength * t * t);
	}
	
	float dd = 1. - pow(1. - d, 3.);
	float hn = (2. * h - hp + k * lap) * dd;
	
	gl_FragColor = vec4(hn, h, 0, 1);
}