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

uniform int useSampler;

float random (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898 * seed, 78.233))) * 43758.5453123);
}

void main() {
	vec2 st = v_vTexcoord - position / dimension;
    vec2 pos = vec2(st * scale);
	pos.x += random(vec2(0., floor(pos.y))) * shift;
	vec2 i = floor(pos);
    float n = random(i);
	
	if(useSampler == 0)
		gl_FragColor = vec4(vec3(n), 1.0);
	else {
		vec2 samPos = floor(pos) / scale + 0.5 / scale;
		gl_FragColor = texture2D( gm_BaseTexture, samPos );
	}
}
