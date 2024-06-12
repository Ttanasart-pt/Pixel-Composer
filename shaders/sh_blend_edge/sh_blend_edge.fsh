varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  edge;

uniform vec2      width;
uniform int       widthUseSurf;
uniform sampler2D widthSurf;

uniform float blend;
uniform float smooth;

void main() {
	float wid    = width.x;
	float widMax = max(width.x, width.y);
	if(widthUseSurf == 1) {
		vec4 _vMap = texture2D( widthSurf, v_vTexcoord );
		wid = mix(width.x, width.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float bnd = 1. - blend;
	vec4  off;
	float m  = 0.;
	vec2  v  = 1. - max(vec2(0.), (1. - abs(v_vTexcoord - 0.5) * 2.) / wid - bnd) / (1. - bnd);
	
	vec4 c1 = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 c2;
	
	if(edge == 0) { 
		m  = v.x;
		c2 = texture2D( gm_BaseTexture, vec2(fract(v_vTexcoord.x + 0.5), v_vTexcoord.y) );
		
	} else if(edge == 1) { 
		m  = v.y;
		c2 = texture2D( gm_BaseTexture, vec2(v_vTexcoord.x, fract(v_vTexcoord.y + 0.5)) );
		
	} 
	
	m = clamp(m, 0., 1.);
	m = mix(m, smoothstep(0., 1., m), smooth);
	
	gl_FragColor = mix(c1, c2, m);
}
