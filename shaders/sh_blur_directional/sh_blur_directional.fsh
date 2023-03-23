//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float size;
uniform float strength;
uniform float direction;

vec4 dirBlur(vec2 angle) {
    vec4 acc = vec4(0.);
    
    float delta = 1. / size;
    
    for(float i = -1.0; i <= 1.0; i += delta) {
		vec4 col = texture2D( gm_BaseTexture, v_vTexcoord - vec2(angle.x * i, angle.y * i));
        acc += col;
    }
	acc.rgb *= 0.5;
    return acc * delta;
}

void main() {
    float r = radians(direction);
    vec2 dirr = vec2(sin(r), cos(r));
    
    gl_FragColor = dirBlur(strength * dirr);
}