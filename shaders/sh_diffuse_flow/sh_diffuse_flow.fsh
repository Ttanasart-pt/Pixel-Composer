varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float seed;
uniform int   iteration;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform vec2      flowRate;
uniform int       flowRateUseSurf;
uniform sampler2D flowRateSurf;

uniform int   externalForceType;

uniform vec2      externalForce;
uniform int       externalForceUseSurf;
uniform sampler2D externalForceSurf;

uniform vec2      externalForceDir;
uniform int       externalForceDirUseSurf;
uniform sampler2D externalForceDirSurf;


#region ///////////////////// PERLIN START /////////////////////

float random  (in vec2 st) { return smoothstep(0., 1., abs(fract(sin(dot(st.xy + vec2(21.456, 46.856), vec2(12.989, 78.233))) * (43758.545 + seed)) * 2. - 1.)); }
vec2  random2 (in vec2 st) { float a = random(st) * 6.28319; return vec2(cos(a), sin(a)); }

float noise (in vec2 st) {
    vec2 cellMin = floor(st);
    vec2 cellMax = floor(st) + vec2(1., 1.);
	
	vec2 f = fract(st);
	vec2 u = f * f * (3.0 - 2.0 * f);
	
	vec2 _a = vec2(cellMin.x, cellMin.y);
	vec2 _b = vec2(cellMax.x, cellMin.y);
	vec2 _c = vec2(cellMin.x, cellMax.y);
	vec2 _d = vec2(cellMax.x, cellMax.y);
	
	vec2 ai = f - vec2(0., 0.);
    vec2 bi = f - vec2(1., 0.);
    vec2 ci = f - vec2(0., 1.);
    vec2 di = f - vec2(1., 1.);
	
	vec2 a2 = random2(_a);
    vec2 b2 = random2(_b);
    vec2 c2 = random2(_c);
    vec2 d2 = random2(_d);
	
	float l1 = mix(dot(ai, a2), dot(bi, b2), u.x);
	float l2 = mix(dot(ci, c2), dot(di, d2), u.x);
	
    return mix(l1, l2, u.y) + 0.5;
}

float perlin ( vec2 st ) {
	float amp = pow(2., float(iteration) - 1.)  / (pow(2., float(iteration)) - 1.);
    float n   = 0.;
	vec2  pos = st;
	
	for(int i = 0; i < iteration; i++) {
		n += noise(pos) * amp;
		
		amp *= .5;
		pos *= 2.;
	}
	
	return n;
}

#endregion ///////////////////// PERLIN END /////////////////////

void main() {
	#region params
		float sca = scale.x;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float flowR = flowRate.x;
		if(flowRateUseSurf == 1) {
			vec4 _vMap = texture2D( flowRateSurf, v_vTexcoord );
			flowR = mix(flowRate.x, flowRate.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float extF = externalForce.x;
		if(externalForceUseSurf == 1) {
			vec4 _vMap = texture2D( externalForceSurf, v_vTexcoord );
			extF = mix(externalForce.x, externalForce.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float extR = externalForceDir.x;
		if(externalForceDirUseSurf == 1) {
			vec4 _vMap = texture2D( externalForceDirSurf, v_vTexcoord );
			extR = mix(externalForceDir.x, externalForceDir.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		extR = radians(extR);
	#endregion
	
	vec2  tx = 1. / dimension;
	
	float x0 = perlin((v_vTexcoord + vec2(-tx.x, 0.)) * sca);
	float x1 = perlin((v_vTexcoord + vec2( tx.x, 0.)) * sca);
	float y0 = perlin((v_vTexcoord + vec2(0., -tx.y)) * sca);
	float y1 = perlin((v_vTexcoord + vec2(0.,  tx.y)) * sca);
	
	vec2 flow = vec2(x1 - x0, y1 - y0);
	
	if(externalForceType == 0) flow += extF * (v_vTexcoord - 0.5);
	if(externalForceType == 1) flow += extF * vec2(cos(extR), sin(extR));
	
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord - flow * flowR );
}
