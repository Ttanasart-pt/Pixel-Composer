//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;
uniform vec2  position;

uniform vec2      noiseX;
uniform int       noiseXUseSurf;
uniform sampler2D noiseXSurf;

uniform vec2      noiseY;
uniform int       noiseYUseSurf;
uniform sampler2D noiseYSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

float random1D (in vec2 st, float _seed) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233)) * mod(_seed, 32.156) * 12.588) * 43758.5453123); }

float random (in vec2 st) { return mix(random1D(st, floor(seed)), random1D(st, floor(seed) + 1.), fract(seed)); }

void main() {
	#region params
		float nsx = noiseX.x;
		if(noiseXUseSurf == 1) {
			vec4 _vMap = texture2D( noiseXSurf, v_vTexcoord );
			nsx = mix(noiseX.x, noiseX.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float nsy = noiseY.y;
		if(noiseYUseSurf == 1) {
			vec4 _vMap = texture2D( noiseYSurf, v_vTexcoord );
			nsy = mix(noiseY.x, noiseY.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
	#endregion
	
	vec2 pos = v_vTexcoord - position, _pos;
	_pos.x = pos.x * cos(ang) - pos.y * sin(ang);
	_pos.y = pos.x * sin(ang) + pos.y * cos(ang);
	
	float yy = floor(_pos.y * nsy);
	float xx = (_pos.x + random1D(vec2(yy), floor(seed))) * nsx;
	float x0 = floor(xx);
	float x1 = floor(xx) + 1.;
	
	float noise0 = random(vec2(x0, yy));
	float noise1 = random(vec2(x1, yy));
	
    gl_FragColor = vec4(vec3(mix(noise0, noise1, (xx - x0) / (x1 - x0))), 1.);
}
