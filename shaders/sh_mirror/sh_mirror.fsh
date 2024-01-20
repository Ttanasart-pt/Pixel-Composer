varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586
#define pi1 3.14159
#define pi2 1.57079

uniform vec2  dimension;
uniform vec2  position;
uniform float angle;

float angle_different(in float a1, in float a2) { #region
	float _d = (a2 - a1) + pi2;
	return (_d - floor(_d / pi1) * pi1) - pi2;
} #endregion

void main() {
	vec2  pos = v_vTexcoord;
	vec2  pixel_pos = v_vTexcoord * dimension;
	float _angle;
	
	_angle = atan((pixel_pos.y - position.y), (pixel_pos.x - position.x)) + angle;
	_angle = TAU - (_angle - floor(_angle / TAU) * TAU); 
	
	if(_angle < pi1) {
		float _alpha    = (angle + pi1) - (_angle + angle);
		float inv_angle = (angle + pi1) + _alpha;
		float dist      = distance(pixel_pos, position);
		
		pos = (position + vec2(cos(inv_angle) * dist, -sin(inv_angle) * dist )) / dimension;
	} 
	
	gl_FragColor = vec4(0.);
	if(pos.x > 0. && pos.x < 1. && pos.y > 0. && pos.y < 1.)
		gl_FragColor = v_vColour * texture2D( gm_BaseTexture, pos );
}
