//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  position;
uniform vec2  scale;
uniform float angle;
uniform float width;
uniform float shift;
uniform int shiftAxis;

uniform vec4 col1, col2;
uniform int useSampler;

void main() {
	vec2 pos = v_vTexcoord - position, _pos;
	_pos.x = pos.x * cos(angle) - pos.y * sin(angle);
	_pos.y = pos.x * sin(angle) + pos.y * cos(angle);
	
	if(shiftAxis == 0) {
		float cellY = floor(_pos.y * scale.y);
		float shiftX = mod(cellY, 2.) * shift;
	
		_pos.x += shiftX;
	} else {
		float cellX = floor(_pos.x * scale.x);
		float shiftY = mod(cellX, 2.) * shift;
	
		_pos.y += shiftY;
	}
	
	vec2 dist = _pos - floor(_pos * scale) / scale;
	float ww = width / 2.;
	
	if(useSampler == 0) {
		if(dist == clamp(dist, vec2(ww), vec2(1. / scale - ww)))
			gl_FragColor = vec4(col1.rgb, 1.);
		else
			gl_FragColor = vec4(col2.rgb, 1.);
	} else {
		vec2 uv = fract(_pos * scale);
		gl_FragColor = texture2D( gm_BaseTexture, uv );
	}
}
