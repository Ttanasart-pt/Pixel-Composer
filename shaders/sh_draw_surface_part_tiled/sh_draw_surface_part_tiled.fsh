//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec4 parts;

void main() {
	float left   = parts.x / dimension.x;
	float top    = parts.y / dimension.y;
	float width  = parts.z / dimension.x;
	float heigh  = parts.a / dimension.y;
	
	vec2 pos;
	pos.x = fract((v_vTexcoord.x - left) / width) * width + left;
	pos.y = fract((v_vTexcoord.y - top) / heigh) * heigh + top;
	
    gl_FragColor = texture2D( gm_BaseTexture, pos );
}
