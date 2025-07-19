varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int   light;

uniform vec2      exposure;
uniform int       exposureUseSurf;
uniform sampler2D exposureSurf;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

uniform vec2      smoothness;
uniform int       smoothnessUseSurf;
uniform sampler2D smoothnessSurf;

void main() {
	#region 
		float epo = exposure.x;
		if(exposureUseSurf == 1) {
			vec4 _vMap = texture2D( exposureSurf, v_vTexcoord );
			epo = mix(exposure.x, exposure.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float str = strength.x;
		if(strengthUseSurf == 1) {
			vec4 _vMap = texture2D( strengthSurf, v_vTexcoord );
			str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float smo = smoothness.x;
		if(smoothnessUseSurf == 1) {
			vec4 _vMap = texture2D( smoothnessSurf, v_vTexcoord );
			smo = mix(smoothness.x, smoothness.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
	#endregion
	
	vec2 uv  = v_vTexcoord;
	
	vec2  _uv  = v_vTexcoord - 0.5;
	float dist = dot(_uv, _uv);
	float ang  = atan(_uv.y, _uv.x);
	vec2  _sp  = 0.5 + vec2(cos(ang), sin(ang)) * dist;
	
	float smt = smo / 2.;
	uv = mix(uv, _sp, smt);
	
	uv *= 1.0 - uv.yx;
    float vig = uv.x * uv.y * epo;
    
    vig = pow(vig, 0.25 + smt);
	vig = clamp(vig, 0., 1.);
	
	vec4 samp  = texture2D( gm_BaseTexture, v_vTexcoord );
	float strn = (1. - ((1. - vig) * str));
	
	if(light == 1) strn = strn < 0.001? 10000. : 1. / strn;
    gl_FragColor = vec4(samp.rgb * strn, samp.a);
}
