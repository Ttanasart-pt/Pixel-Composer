#pragma use(sampler_simple)
#region -- sampler_simple -- [1765194569.6586206]
    uniform int  sampleMode;
    
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(vec2 tx) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, tx).xy;
            map.y    = 1.0 - map.y;
            tx       = mix(tx, map, uvMapMix);
        }
        return tx;
    }

    vec4 sampleTexture( sampler2D texture, vec2 pos, float mapBlend) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, pos).xy;
            map.y    = 1.0 - map.y;
            pos      = mix(pos, map, mapBlend * uvMapMix);
        }

        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
			 if(sampleMode <= 1) return vec4(0.);
		else if(sampleMode == 2) return vec4(0.,0.,0., 1.);
		else if(sampleMode == 3) return texture2D(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 4) return texture2D(texture, fract(pos));
        // 5
		else if(sampleMode == 6) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.) : texture2D(texture, sp); } 
		else if(sampleMode == 7) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.,0.,0.,1.) : texture2D(texture, sp); } 
		else if(sampleMode == 8) return texture2D(texture, vec2(fract(pos.x), clamp(pos.y, 0., 1.)));
		// 9
		else if(sampleMode == 10) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.) : texture2D(texture, sp); } 
		else if(sampleMode == 11) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.,0.,0.,1.) : texture2D(texture, sp); } 
		else if(sampleMode == 12) return texture2D(texture, vec2(clamp(pos.x, 0., 1.), fract(pos.y)));
		
        return vec4(0.);
    }
    vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler_simple --


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

uniform int       externalForceType;

uniform vec2      externalForce;
uniform int       externalForceUseSurf;
uniform sampler2D externalForceSurf;

uniform vec2      externalForceDir;
uniform int       externalForceDirUseSurf;
uniform sampler2D externalForceDirSurf;

uniform vec2      externalForcePos;
uniform float     externalForceRad;

uniform int       flowmapUse;
uniform sampler2D flowmap;

uniform float iter;

#region //// PERLIN

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

#region //// SIMPLEX

vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permute(vec4 x) { return mod289(((x * 34.0) + 10.0) * x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float snoise(vec3 vec) {
	vec3 v  = vec * 4.;
	
	const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
	const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

	// First corner
	vec3 i  = floor(v + dot(v, C.yyy));
	vec3 x0 =   v - i + dot(i, C.xxx);
	
	// Other corners
	vec3 g = step(x0.yzx, x0.xyz);
	vec3 l = 1.0 - g;
	vec3 i1 = min( g.xyz, l.zxy );
	vec3 i2 = max( g.xyz, l.zxy );
	
	//   x0 = x0 - 0.0 + 0.0 * C.xxx;
	//   x1 = x0 - i1  + 1.0 * C.xxx;
	//   x2 = x0 - i2  + 2.0 * C.xxx;
	//   x3 = x0 - 1.0 + 3.0 * C.xxx;
	vec3 x1 = x0 - i1 + C.xxx;
	vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
	vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

	// Permutations
	i = mod289(i);
	
	vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));
	
	// Gradients: 7x7 points over a square, mapped onto an octahedron.
	// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
	float n_ = 0.142857142857; // 1.0/7.0
	vec3  ns = n_ * D.wyz - D.xzx;
	
	vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)
	
	vec4 x_ = floor(j * ns.z);
	vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)
	
	vec4 x = x_ * ns.x + ns.yyyy;
	vec4 y = y_ * ns.x + ns.yyyy;
	vec4 h = 1.0 - abs(x) - abs(y);
	
	vec4 b0 = vec4( x.xy, y.xy );
	vec4 b1 = vec4( x.zw, y.zw );
	
	//vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
	//vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
	vec4 s0 = floor(b0) * 2.0 + 1.0;
	vec4 s1 = floor(b1) * 2.0 + 1.0;
	vec4 sh = -step(h, vec4(0.0));
	
	vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy ;
	vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww ;
	
	vec3 p0 = vec3(a0.xy, h.x);
	vec3 p1 = vec3(a0.zw, h.y);
	vec3 p2 = vec3(a1.xy, h.z);
	vec3 p3 = vec3(a1.zw, h.w);

	//Normalise gradients
	vec4 norm = taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;

	// Mix final noise value
	vec4 m = max(0.5 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
	m = m * m;
	
	float n = 105.0 * dot( m * m, vec4( dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3) ) );
	n = mix(0.0, 0.5 + 0.5 * n, smoothstep(0.0, 0.003, vec.z));
	return n;
}

float simplex(in vec2 ntx, in float Z) {
	vec2 st  = ntx;
    vec2 p   = st;
	float _z = 1. + Z;
    vec3 xyz = vec3(p, _z);
    
	float amp = pow(2., float(iteration) - 1.)  / (pow(2., float(iteration)) - 1.);
    float n = 0.;
    
	for(float i = 0.; i < float(iteration); i++) {
		n   += snoise(xyz) * amp;
		amp *= 2.;
		xyz *= 2.;
	}
	
	return n;
}

#endregion

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
	
	vec2 tx = 1. / dimension;
	vec2 txpos = v_vTexcoord;
	vec2 flow;
	
	if(flowmapUse == 0) {
		float x0 = perlin((v_vTexcoord + vec2(-tx.x, 0.)) * sca);
		float x1 = perlin((v_vTexcoord + vec2( tx.x, 0.)) * sca);
		float y0 = perlin((v_vTexcoord + vec2(0., -tx.y)) * sca);
		float y1 = perlin((v_vTexcoord + vec2(0.,  tx.y)) * sca);
		
		flow = vec2(x1 - x0, y1 - y0);	
		
	} else {
		vec4  d0 = texture2D( flowmap, v_vTexcoord + vec2( tx.x, 0.) ); float h0 = (d0.r + d0.g + d0.b) / 3.;
		vec4  d1 = texture2D( flowmap, v_vTexcoord - vec2( 0., tx.y) ); float h1 = (d1.r + d1.g + d1.b) / 3.;
		vec4  d2 = texture2D( flowmap, v_vTexcoord - vec2( tx.x, 0.) ); float h2 = (d2.r + d2.g + d2.b) / 3.;
		vec4  d3 = texture2D( flowmap, v_vTexcoord + vec2( 0., tx.y) ); float h3 = (d3.r + d3.g + d3.b) / 3.;
		vec2 grad  = vec2( h0 - h2, h3 - h1 );
		flow = grad;
		
	}
	
	txpos -= flow * flowR / iter;
	
	if(externalForceType == 0) {
		vec2  exPos = externalForcePos / dimension;
		vec2  exFor = v_vTexcoord - exPos;
		
		float exDis = length(exFor) / externalForceRad;
		      exDis = max(0., 1. - (exDis * 2.));
		
		txpos -= extF * exFor * exDis / iter / 10.;
		
	} else if(externalForceType == 1)
		txpos += extF * vec2(-cos(extR), sin(extR)) / iter / 10.;
	
    gl_FragColor = sampleTexture( gm_BaseTexture, txpos);
}
