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

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

uniform float seed;
uniform float amplitude;

uniform float ridgeScale;
uniform float ridgeAngle;
uniform float ridgeContrast;

uniform int   ridgeMultiply;
uniform float ridgeMulFactor;

uniform float cellScale;

uniform int   mode;
uniform int   blendMode;

#define PI  3.141592653589793
#define TAU 6.283185307179586

vec2 random2( vec2 p ) { return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453); }

float strip(in vec2 p, in vec2 o, in float r, in float s) {
	vec2  d  = (p - o) * mat2(cos(r), -sin(r), sin(r), cos(r));
	float rd = 0.;
	
	     if(mode == 0) rd = cos(d.y * s);
	else if(mode == 1) rd = abs(fract(d.y / TAU * s) - .5) * 4. - 1.;
	
	return (1. - ridgeContrast) + ridgeContrast * rd;
}

float sampleHeight(vec2 uv) { return texture2D( gm_BaseTexture, uv ).x; }

void main() {
	vec2  tx  = 1. / dimension;
	vec2  vtx = getUV(v_vTexcoord);
	vec2  ntx = vtx * vec2(1., dimension.y / dimension.x);
	float ang = radians(rotation);
    vec2  pos = (ntx - position / dimension) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * scale;
	
    vec4  base   = texture2D( gm_BaseTexture, v_vTexcoord );
    float height = base.r;
    
	vec2  grad = vec2( sampleHeight(v_vTexcoord + vec2(0., tx.y)) - sampleHeight(v_vTexcoord - vec2(0., tx.y)),
		               sampleHeight(v_vTexcoord + vec2(tx.x, 0.)) - sampleHeight(v_vTexcoord - vec2(tx.x, 0.)) );
	
	float dir  = atan(grad.y, grad.x) + PI / 2. + radians(ridgeAngle);
	float dis  = length(grad) * ridgeMulFactor;
	
	//// Cell
	vec2 ori = vec2(.5);
	if(cellScale > 0.) {
		vec2 cScale = scale * cellScale;
		vec2 st     = pos * cScale;
	    vec2 i_st   = floor(st);
	    vec2 f_st   = fract(st);
	
	    float md  = 100.;
		
	    for (int y = -1; y <= 1; y++)
	    for (int x = -1; x <= 1; x++) {
	        vec2 neighbor = vec2(float(x), float(y));
	        vec2 point    = random2(i_st + neighbor);
			     point    = .5 + .5 * sin(seed + TAU * point);
			
	        float dist = distance(f_st, neighbor + point);
			
			if(dist < md) {
				ori = i_st + neighbor + point;
				md  = dist;
			}
	    }
	    
	    ori /= cScale;
	}
	
	float str = max(0., strip(pos, ori, dir, ridgeScale));
	if(ridgeMultiply == 1) str *= dis;
	
	float hgh = (pow(2. * height - 1., 3.) + 1.) / 2.;
	// float hgh = height;
	
	if(blendMode == 0) {
		float rid = str * hgh * amplitude;
		gl_FragColor = base + vec4(rid, rid, rid, 1.);
		
	} else if(blendMode == 1) {
		float rid = hgh > 0.5? (1. - (1. - 2. * (hgh - 0.5)) * (1. - str)) : ((2. * hgh) * str);	
		gl_FragColor = vec4(max(base.rgb, vec3(rid)), 1.);
		
	}
}
