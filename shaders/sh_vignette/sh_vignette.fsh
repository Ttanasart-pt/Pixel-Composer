varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float exposure;
uniform float strength;
uniform float amplitude;
uniform float smoothness;
uniform int   light;

void main() {
	vec2 uv  = v_vTexcoord;
	
	vec2  _uv  = v_vTexcoord - 0.5;
	float dist = dot(_uv, _uv);
	float ang  = atan(_uv.y, _uv.x);
	vec2  _sp  = 0.5 + vec2(cos(ang), sin(ang)) * dist;
	
	float smt = smoothness / 2.;
	uv = mix(uv, _sp, smt);
	
	uv *= 1.0 - uv.yx;
    float vig = uv.x * uv.y * exposure;
    
    vig = pow(vig, 0.25 + smt);
	vig = clamp(vig, 0., 1.);
	
	vec4 samp = texture2D( gm_BaseTexture, v_vTexcoord );
	float str = (1. - ((1. - vig) * strength));
	
	if(light == 1) str = str < 0.001? 10000. : 1. / str;
    gl_FragColor = vec4(samp.rgb * str, samp.a);
}
