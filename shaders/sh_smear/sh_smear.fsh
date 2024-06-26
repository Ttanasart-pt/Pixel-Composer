varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float size;
uniform float spread;

uniform vec2      direction;
uniform int       directionUseSurf;
uniform sampler2D directionSurf;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

uniform int	sampleMode;
uniform int	alpha;
uniform int	modulateStr;

vec4 sampleTexture(vec2 pos) { #region
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
		
	else if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));
		
	else if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	else if(sampleMode == 3) 
		return vec4(vec3(0.), 1.);
		
	return vec4(0.);
} #endregion

vec4 smear(vec2 angle) { #region
	float delta  = 1. / size;
	
	vec4  base      = sampleTexture( v_vTexcoord );
	float maxBright = (base.r + base.g + base.b) / 3. * base.a;
    vec4  res       = base;
	
	for(float i = 0.; i <= 1.0; i += delta) {
		vec4  col    = sampleTexture( v_vTexcoord - angle * i);
		
		if(modulateStr != 2) {
			if(alpha == 0) col.rgb *= 1. - i;
			else           col.a *= 1. - i;
		}
			  
	    float bright = (col.r + col.g + col.b) / 3. * col.a;
		
		if(bright > maxBright) {
			maxBright = bright;
			res = col;
		}
	}
	
	if(modulateStr == 1) {
		if(alpha == 0) res.rgb *= maxBright;
		else           res.a   *= res.a;
	}
	
    return res;
} #endregion

void main() {
	float str = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = texture2D( strengthSurf, v_vTexcoord );
		str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float dir = direction.x;
	if(directionUseSurf == 1) {
		vec4 _vMap = texture2D( directionSurf, v_vTexcoord );
		dir = mix(direction.x, direction.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4 col = vec4(0.);
	
	for(float i = -spread; i <= spread; i++) {
		float r    = radians(dir + 90. + i);
		vec2  dirr = vec2(sin(r), cos(r)) * str;
		vec4  smr  = smear(dirr);
		
		col = max(col, smr);
	}
	
    gl_FragColor = col;
}