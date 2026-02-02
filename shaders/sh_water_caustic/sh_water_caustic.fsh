#pragma use(uv)

#region -- uv -- [1770002023.9166503]
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vuv   = texture2D( uvMap, uv ).xy;
             vuv.y = 1.0 - vuv.y;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }
#endregion -- uv --

//Caustic noise by jaybird
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;
uniform int   detail;

uniform vec2      progress;
uniform int       progressUseSurf;
uniform sampler2D progressSurf;

uniform vec2      intensity;
uniform int       intensityUseSurf;
uniform sampler2D intensitySurf;

uniform vec2  dimension;
uniform vec2  position;
uniform vec2  scale;

vec4 mod289(vec4 x) { return x - floor(x / 289.0) * 289.0; }
vec4 permute(vec4 x) { return mod289((x * 34.0 + 1.0) * x); }

vec4 snoise(vec3 v) {
    const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);

    // First corner
    vec3 i  = floor(v + dot(v, vec3(C.y)));
    vec3 x0 = v   - i + dot(i, vec3(C.x));

    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);

    vec3 x1 = x0 - i1 + C.x;
    vec3 x2 = x0 - i2 + C.y;
    vec3 x3 = x0 - 0.5;

    // Permutations
    vec4 p =
      permute(permute(permute(i.z + vec4(0.0, i1.z, i2.z, 1.0))
                            + i.y + vec4(0.0, i1.y, i2.y, 1.0))
                            + i.x + vec4(0.0, i1.x, i2.x, 1.0));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    vec4 j = p - 49.0 * floor(p / 49.0);  // mod(p,7*7)

    vec4 x_ = floor(j / 7.0);
    vec4 y_ = floor(j - 7.0 * x_); 

    vec4 x = (x_ * 2.0 + 0.5) / 7.0 - 1.0;
    vec4 y = (y_ * 2.0 + 0.5) / 7.0 - 1.0;

    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);

    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    vec3 g0 = vec3(a0.xy, h.x);
    vec3 g1 = vec3(a0.zw, h.y);
    vec3 g2 = vec3(a1.xy, h.z);
    vec3 g3 = vec3(a1.zw, h.w);

    // Compute noise and gradient at P
    vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    vec4 m2 = m * m;
    vec4 m3 = m2 * m;
    vec4 m4 = m2 * m2;
    vec3 grad =
      -6.0 * m3.x * x0 * dot(x0, g0) + m4.x * g0 +
      -6.0 * m3.y * x1 * dot(x1, g1) + m4.y * g1 +
      -6.0 * m3.z * x2 * dot(x2, g2) + m4.z * g2 +
      -6.0 * m3.w * x3 * dot(x3, g3) + m4.w * g3;
    vec4 px = vec4(dot(x0, g0), dot(x1, g1), dot(x2, g2), dot(x3, g3));
    return 42.0 * vec4(grad, dot(m4, px));
}

void main() {
	float prg = progress.x;
	if(progressUseSurf == 1) {
		vec4 _vMap = texture2D( progressSurf, v_vTexcoord );
		prg = mix(progress.x, progress.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float its = intensity.x;
	if(intensityUseSurf == 1) {
		vec4 _vMap = texture2D( intensitySurf, v_vTexcoord );
		its = mix(intensity.x, intensity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 vtx  = getUV(v_vTexcoord);
	vec2 p    = vtx;
	     p.x *= (dimension.x / dimension.y);
         p    = (p - position / dimension) * dimension / scale;
	
    float amp = pow(2., float(detail) - 1.) / (pow(2., float(detail)) - 1.);
    float cc  = 0.;
    
    for(int i = 0; i < detail; i++) {
    	vec3 pos = vec3(p.x, prg, p.y);
	    vec4 n   = snoise( pos );
	    pos -= 0.07 * n.xyz;
	    n = snoise( pos );
	
	    pos -= 0.07 * n.xyz;
	    n = snoise( pos );
	    cc += exp(n.w * 3. - 1.5) * its * amp;
	    
		amp *= .5;
		p   *= 2.;
    }
	
	gl_FragColor = vec4(vec3(cc), 1.);
}
