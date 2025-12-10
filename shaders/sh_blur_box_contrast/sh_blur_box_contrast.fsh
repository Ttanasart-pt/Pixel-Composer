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

#define TAU 6.283185307179586
#define MAX_STRENGTH 64.

uniform vec2  dimension;
uniform int   gamma;

uniform vec2      size;
uniform int       sizeUseSurf;
uniform sampler2D sizeSurf;

uniform vec2      treshold;
uniform int       tresholdUseSurf;
uniform sampler2D tresholdSurf;

vec3 rgb2xyz( vec3 c ) {
    vec3 tmp;
    tmp.x = ( c.r > 0.04045 ) ? pow( ( c.r + 0.055 ) / 1.055, 2.4 ) : c.r / 12.92;
    tmp.y = ( c.g > 0.04045 ) ? pow( ( c.g + 0.055 ) / 1.055, 2.4 ) : c.g / 12.92,
    tmp.z = ( c.b > 0.04045 ) ? pow( ( c.b + 0.055 ) / 1.055, 2.4 ) : c.b / 12.92;
    return 100.0 * tmp *
        mat3( 0.4124, 0.3576, 0.1805,
              0.2126, 0.7152, 0.0722,
              0.0193, 0.1192, 0.9505 );
}

vec3 xyz2lab( vec3 c ) {
    vec3 n = c / vec3( 95.047, 100, 108.883 );
    vec3 v;
    v.x = ( n.x > 0.008856 ) ? pow( n.x, 1.0 / 3.0 ) : ( 7.787 * n.x ) + ( 16.0 / 116.0 );
    v.y = ( n.y > 0.008856 ) ? pow( n.y, 1.0 / 3.0 ) : ( 7.787 * n.y ) + ( 16.0 / 116.0 );
    v.z = ( n.z > 0.008856 ) ? pow( n.z, 1.0 / 3.0 ) : ( 7.787 * n.z ) + ( 16.0 / 116.0 );
    return vec3(( 116.0 * v.y ) - 16.0, 500.0 * ( v.x - v.y ), 200.0 * ( v.y - v.z ));
}

vec3 rgb2lab(vec3 c) {
    vec3 lab = xyz2lab( rgb2xyz( c ) );
    return vec3( lab.x / 100.0, 0.5 + 0.5 * ( lab.y / 127.0 ), 0.5 + 0.5 * ( lab.z / 127.0 ));
}

float colorDifferent(in vec4 c1, in vec4 c2) {
	return length(c1.rgb - c2.rgb) / 1.7320508076;
}

void main() {
	float siz = size.x;
	if(sizeUseSurf == 1) {
		vec4 _vMap = texture2D( sizeSurf, v_vTexcoord );
		siz = mix(size.x, size.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float tre = treshold.x;
	if(tresholdUseSurf == 1) {
		vec4 _vMap = texture2D( tresholdSurf, v_vTexcoord );
		tre = mix(treshold.x, treshold.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2  tx  = 1. / dimension;
	vec4  col = texture2D( gm_BaseTexture, v_vTexcoord);
	vec4  c   = col;
	float div = 1.;
	float sz2 = siz * siz;
	
	for(float i = -MAX_STRENGTH; i <= MAX_STRENGTH; i++)
	for(float j = -MAX_STRENGTH; j <= MAX_STRENGTH; j++) {
		float dist = i * i + j * j;
		if(dist >= sz2) continue;
		
		float amp = 1. - dist / sz2;
		vec2 pxs  = v_vTexcoord + vec2( i, j ) * tx;
		vec4 bcol = sampleTexture( gm_BaseTexture, pxs, 1. - amp);
		
		if(c.a == bcol.a && colorDifferent(c, bcol) <= tre) {
			if(gamma == 1) bcol.rgb = pow(bcol.rgb, vec3(2.2));
			
			col += bcol * amp;
			div += amp;
		}
	}
	
	vec4 res = col / div;
	if(gamma == 1) res.rgb = pow(res.rgb, vec3(1. / 2.2));
	
	gl_FragColor = res;
}
