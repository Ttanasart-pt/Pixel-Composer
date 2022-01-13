//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 center;
uniform float strength;
uniform float radius;

void main() {
	vec2 pixelPos = v_vTexcoord * dimension;
	vec2 to		= pixelPos - center;
	float dis	= distance(center, pixelPos);
	float eff	= 1. - clamp(dis / radius, 0., 1.);
	float ang	= atan(to.y, to.x) + eff * strength;
	
	vec2 tex = center / dimension + vec2(cos(ang), sin(ang)) * distance(center / dimension, v_vTexcoord);
    gl_FragColor = v_vColour * texture2D( gm_BaseTexture, tex );
}
