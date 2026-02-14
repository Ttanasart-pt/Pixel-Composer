varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int axis;

void main() {
	vec2 pos = v_vTexcoord;
	if(axis == 1 || axis == 3) pos.x = 1. - pos.x;
	if(axis == 2 || axis == 3) pos.y = 1. - pos.y;
	
    gl_FragColor = texture2D( gm_BaseTexture, pos );
}
