//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform vec2  scale;
uniform float seed;
uniform float shift;
uniform int shiftAxis;

uniform int useSampler;

float randomSeed (in vec2 st, float _seed) {
    return fract(sin(dot(st.xy + vec2(5.0654, 9.684), vec2(12.9898, 78.233))) * (43758.5453123 + _seed));
}

float random (in vec2 st) {
    return mix(randomSeed(st, floor(seed)), randomSeed(st, floor(seed) + 1.), fract(seed));
}

void main() {
	vec2 st = v_vTexcoord - position / dimension;
    vec2 pos = vec2(st * scale);
	
	if(shiftAxis == 0) {
		//pos.x += random(vec2(0., floor(pos.y)));
		if(mod(pos.y, 2.) > 1.)
			pos.x += shift;
	} else if(shiftAxis == 1) {
		//pos.y += random(vec2(0., floor(pos.x)));
		if(mod(pos.x, 2.) > 1.)
			pos.y += shift;
	}
	
	if(useSampler == 0) {
		vec2 i = floor(pos);
		float n = random(i);
		gl_FragColor = vec4(vec3(n), 1.0);
	} else {
		vec2 samPos = floor(pos) / scale + 0.5 / scale;
		gl_FragColor = texture2D( gm_BaseTexture, samPos );
	}
}
