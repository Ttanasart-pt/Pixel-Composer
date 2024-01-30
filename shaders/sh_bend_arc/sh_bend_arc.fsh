varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265358979323846;

uniform vec2  position;
uniform float amount;

void main() {
	//vec2  cen   = v_vTexcoord - position;
	//float angle	= (atan(cen.y, cen.x) / PI + 1.) / 2.;
	//float dist  = length(cen);
	
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
}
