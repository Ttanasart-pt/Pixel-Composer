//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform vec2  scale;
uniform float seed;

uniform int useSampler;

float random (in vec2 st, float seed) {
    return fract(sin(dot(st.xy + seed, vec2(1892.9898, 78.23453))) * 437.54123);
}

vec2 triChecker(vec2 p) {
    p.x += fract(p.y * .5);
    vec2 m = fract(p); 
    vec2 base = p - m;
    
    base.x *= 2. + step(m.x, m.y);
    
    return base;
}

void main() {
	vec2 pos = (v_vTexcoord - position / dimension) * scale;
	pos.y *= 1.1;
	vec2 hx = triChecker(pos);
	
	if(useSampler == 0) {
		float n0 = random(hx, floor(seed) / 5000.);
		float n1 = random(hx, (floor(seed) + 1.) / 5000.);
		float n  = mix(n0, n1, fract(seed));
		gl_FragColor = vec4(vec3(n), 1.0);
	} else {
		vec2 samPos = floor(hx) / scale + 0.5 / scale;
		gl_FragColor = texture2D( gm_BaseTexture, samPos );
	}
}