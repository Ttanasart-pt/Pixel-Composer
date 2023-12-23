//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 position;

uniform vec2      amount;
uniform int       amountUseSurf;
uniform sampler2D amountSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec4 col1;
uniform vec4 col2;

void main() {
	#region params
		float amo = amount.x;
		if(amountUseSurf == 1) {
			vec4 _vMap = texture2D( amountSurf, v_vTexcoord );
			amo = mix(amount.x, amount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
	#endregion
	
	vec2 dimension_norm = dimension / dimension.y;
	vec2 c   = (v_vTexcoord - position) * dimension_norm;
	float _x = c.x * cos(ang) - c.y * sin(ang);
	float _y = c.x * sin(ang) + c.y * cos(ang);
	float _a = 1. / amo;
	
	if(mod(floor(_x / _a) + floor(_y / _a), 2.) > 0.5)
		gl_FragColor = vec4(col1.rgb, 1.);
	else
		gl_FragColor = vec4(col2.rgb, 1.);
}
