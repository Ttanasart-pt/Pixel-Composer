//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float scale;
uniform int   axis;
uniform int   shift;

void main() {
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	if(gl_FragColor.a == 0.) return;
	
	vec2  pos  = v_vTexcoord * dimension;
	float prog = axis == 0? pos.x : pos.y;
	prog -= float(shift);
	prog /= scale;
	
	prog = prog - floor(prog / 2.) * 2.;
	if(prog >= 1.) gl_FragColor = v_vColour;
}
