varying vec2 v_vTexcoord;
varying vec4 v_vColour;

const float PI  = 3.14159265;
const float ATR = PI / 180.;

uniform int   iteration;

uniform vec2      brushLen;
uniform int       brushLenUseSurf;
uniform sampler2D brushLenSurf;

uniform vec2      brushAtn;
uniform int       brushAtnUseSurf;
uniform sampler2D brushAtnSurf;

uniform vec2      brushRot;
uniform int       brushRotUseSurf;
uniform sampler2D brushRotSurf;

uniform vec2  dimension;
uniform float seed;

vec4  getCol( vec2 pos ) { return        texture2D( gm_BaseTexture, pos / dimension);  }
float getD(   vec2 pos ) { return length(texture2D( gm_BaseTexture, pos / dimension)); }

vec2 grad( vec2 pos, float delta) {
    vec2  e = vec2(1., 0.) * delta;
    float o = getD(pos);
    return vec2(getD(pos + e.xy) - o, getD(pos + e.yx) - o) / delta;
}

void main() {
    float len = brushLen.x;
	if(brushLenUseSurf == 1) {
		vec4 _vMap = texture2D( brushLenSurf, v_vTexcoord );
		len = mix(brushLen.x, brushLen.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float atn = brushAtn.x;
	if(brushAtnUseSurf == 1) {
		vec4 _vMap = texture2D( brushAtnSurf, v_vTexcoord );
		atn = mix(brushAtn.x, brushAtn.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float rot = brushRot.x;
	if(brushRotUseSurf == 1) {
		vec4 _vMap = texture2D( brushRotSurf, v_vTexcoord );
		rot = mix(brushRot.x, brushRot.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    vec2  pos = v_vTexcoord * dimension;
    float r   = 1.;
    float acc = 0.;
    vec4  res = vec4(0.);
    vec2  dir;
    
    for(int i = 0; i < iteration; i++) {
        res += getCol(pos) * r;
        dir  = grad(pos, len) + vec2(1) * 0.001;
        pos += 2. * normalize(mix(dir, dir.yx * vec2(1, -1), rot));
        acc += r;
        r   *= atn;
    }
    
    res.xyz /= acc;
    
    gl_FragColor = res;
}
