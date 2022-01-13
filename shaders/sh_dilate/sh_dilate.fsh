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
	vec2 to		= center - pixelPos;
	float dis	= distance(center, pixelPos);
	float eff	= 1. - clamp(dis / radius, 0., 1.);
	
	vec2 tex = pixelPos + to * eff * strength;
	tex /= dimension;
    gl_FragColor = v_vColour * texture2D( gm_BaseTexture, tex );
}
