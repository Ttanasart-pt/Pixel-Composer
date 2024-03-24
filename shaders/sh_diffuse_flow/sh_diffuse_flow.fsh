varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float seed;
uniform float scale;
uniform int   iteration;
uniform float flowRate;

uniform int   externalForceType;
uniform float externalForce;
uniform float externalForceDir;

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
	vec2  tx   = 1. / dimension;
	
	float x0 = perlin((v_vTexcoord + vec2(-tx.x, 0.)) * scale);
	float x1 = perlin((v_vTexcoord + vec2( tx.x, 0.)) * scale);
	float y0 = perlin((v_vTexcoord + vec2(0., -tx.y)) * scale);
	float y1 = perlin((v_vTexcoord + vec2(0.,  tx.y)) * scale);
	
	vec2 flow = vec2(x1 - x0, y1 - y0);
	
	if(externalForceType == 0) 
		flow += externalForce * (v_vTexcoord - 0.5);
	if(externalForceType == 1) 
		flow += externalForce * vec2(cos(externalForceDir), sin(externalForceDir));
	
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord - flow * flowRate );
}
