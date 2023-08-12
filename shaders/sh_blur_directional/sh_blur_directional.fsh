//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float size;
uniform float strength;
uniform float direction;
uniform int	  sampleMode;

vec4 sampleTexture(vec2 pos) {
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
	if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));
	if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	return vec4(0.);
}

vec4 dirBlur(vec2 angle) {
    vec4 acc    = vec4(0.);
    float delta = 1. / size;
	float weight = 0.;
    
    for(float i = -1.0; i <= 1.0; i += delta) {
		vec4 col = sampleTexture( v_vTexcoord - angle * i);
        acc    += col;
		weight += col.a;
    }
	acc.rgb /= weight;
	acc.a   /= size * 2.;
	
    return acc;
}

void main() {
    float r = radians(direction);
    vec2 dirr = vec2(sin(r), cos(r));
    
    gl_FragColor = dirBlur(strength * dirr);
}