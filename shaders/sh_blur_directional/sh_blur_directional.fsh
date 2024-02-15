//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float size;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

uniform vec2      direction;
uniform int       directionUseSurf;
uniform sampler2D directionSurf;

uniform int	  sampleMode;

vec4 sampleTexture(vec2 pos) { #region
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
		
	else if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));\
		
	else if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	else if(sampleMode == 3) 
		return vec4(vec3(0.), 1.);
		
	return vec4(0.);
} #endregion

vec4 dirBlur(vec2 angle) { #region
    vec4 acc    = vec4(0.);
    float delta = 1. / size;
	float weight = 0.;
    
    for(float i = -1.0; i <= 1.0; i += delta) {
		vec4 col = sampleTexture( v_vTexcoord - angle * i);
        acc    += col;
		weight += col.a;
    }
	acc.rgb /= weight;
	acc.a   /= size * 2.;
	
    return acc;
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
	
    float r = radians(dir + 90.);
    vec2 dirr = vec2(sin(r), cos(r)) * str;
    
    gl_FragColor = dirBlur(dirr);
}