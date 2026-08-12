varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D surf_x;
uniform sampler2D surf_y;

void main() {
	vec4 sx = texture2D(surf_x, v_vTexcoord);
	vec4 sy = texture2D(surf_y, v_vTexcoord);
	
	gl_FragColor = vec4(sx.x, sy.y, 0., sx.a) * v_vColour;
}