varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  radius;
uniform int  channels;

void main() {
	vec2 tx = 1. / dimension;
	vec3  _cmin = vec3(1.);
	vec3  _cmax = vec3(0.);
	float _lmin = 1.;
	float _lmax = 1.;
	
	vec4  cc = texture2D(gm_BaseTexture, v_vTexcoord);
	float bb = dot(cc.rgb, vec3(0.2126, 0.7152, 0.0722));
	
	for(int i = -radius; i <= radius; i++)
	for(int j = -radius; j <= radius; j++) {
		vec2  _offsNorm = vec2(float(i) / float(radius), float(j) / float(radius));
		float _inf = length(_offsNorm);
		if(_inf > 1.) continue;
		
		float inf = smoothstep(0., 1., 1. - _inf);
		
		vec4  c = texture2D(gm_BaseTexture, v_vTexcoord + vec2(float(i), float(j)) * tx);
		float b = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
		
		vec3 _c = c.rgb + (cc.rgb - c.rgb) * inf;
		_cmin = min(_cmin, _c);
		_cmax = max(_cmax, _c);
		
		float _b = bb + (b - bb) * inf;
		_lmin = min(_lmin, _b);
		_lmax = max(_lmax, _b);
	}
	
	if(channels == 0) {
		vec3 clr = (cc.rgb - _lmin) / (_lmax - _lmin);
		gl_FragColor = vec4(clr, cc.a);
		
	} else {
		vec3 clr = (cc.rgb - _cmin) / (_cmax - _cmin);
		gl_FragColor = vec4(clr, cc.a);
		
	}
	
}