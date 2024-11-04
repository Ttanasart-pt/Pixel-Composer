#pragma use(sampler)

#region -- sampler -- [1730686036.7372286]
	uniform int  interpolation;
	uniform vec2 sampleDimension;
	uniform int  sampleMode;

	const float PI = 3.14159265358979323846;
	float sinc ( float x ) { return x == 0.? 1. : sin(x * PI) / (x * PI); }

	vec4 texture2D_bicubic( sampler2D texture, vec2 uv ) {
		uv = uv * sampleDimension + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		uv = iuv + fuv * fuv * (3.0 - 2.0 * fuv);
		uv = (uv - 0.5) / sampleDimension;
		return texture2D( texture, uv );
	}

	const int RSIN_RADIUS = 1;
	vec4 texture2D_rsin( sampler2D texture, vec2 uv ) {
		vec2 tx = 1.0 / sampleDimension;
		vec2 p  = uv * sampleDimension;
		
		vec4  col = vec4(0.);
		float wei = 0.;
		
		for (int x = -RSIN_RADIUS; x <= RSIN_RADIUS; x++)
		for (int y = -RSIN_RADIUS; y <= RSIN_RADIUS; y++) {
			vec2 sx = vec2(float(x), float(y));
			float a = length(sx) / float(RSIN_RADIUS);
			// if(a > 1.) continue;
			
			vec4 sample = texture2D(texture, uv + sx * tx);
			float w     = sinc(a * PI * tx.x) * sinc(a * PI * tx.y);
			
			col += w * sample;
			wei += w;
		}
		
		col /= wei;
		return col;
	}

	const int LANCZOS_RADIUS = 3;
	float lanczosWeight(float d, float n) { return d == 0.0 ? 1.0 : (d * d < n * n ? sinc(d) * sinc(d / n) : 0.0); }

	vec4 texture2D_lanczos3( sampler2D texture, vec2 uv ) {
		vec2 center = uv - (mod(uv * sampleDimension, 1.0) - 0.5) / sampleDimension;
		vec2 offset = (uv - center) * sampleDimension;
		vec2 tx = 1. / sampleDimension;
		
		vec4  col = vec4(0.);
		float wei = 0.;
		
		for(int x = -LANCZOS_RADIUS; x < LANCZOS_RADIUS; x++)
		for(int y = -LANCZOS_RADIUS; y < LANCZOS_RADIUS; y++) {
			
			float wx = lanczosWeight(float(x) - offset.x, float(LANCZOS_RADIUS));
			float wy = lanczosWeight(float(y) - offset.y, float(LANCZOS_RADIUS));
			float w  = wx * wy;
			
			col += w * texture2D(texture, center + vec2(x, y) * tx);
			wei += w;
		}
		
		col /= wei;
		return col;
	}

	vec4 texture2Dintp( sampler2D texture, vec2 uv ) {
			 if(interpolation <= 2)	return texture2D(          texture, uv );
		else if(interpolation == 3)	return texture2D_bicubic(  texture, uv );
		else if(interpolation == 4)	return texture2D_lanczos3( texture, uv );
		
		return texture2D( texture, uv );
	}

	vec4 sampleTexture( sampler2D texture, vec2 pos) {
		if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
			return texture2Dintp(texture, pos);
		
			 if(sampleMode <= 1) return vec4(0.);
		else if(sampleMode == 2) return texture2Dintp(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 3) return texture2Dintp(texture, fract(pos));
		else if(sampleMode == 4) return vec4(vec3(0.), 1.);
		
		return vec4(0.);
	}
#endregion -- sampler --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  pos1;
uniform vec2  pos2;
uniform int   usePath;
uniform int   pathResolution;
uniform vec2  pathList[1024];

uniform float radius;
uniform float radius2;
uniform float intensity;
uniform float falloff;
uniform float pushIntens;

vec2 closestPointOnLine(vec2 P, vec2 A, vec2 B, out float t) {
    vec2 AP = P - A;
    vec2 AB = B - A;
    t = dot(AP, AB) / dot(AB, AB);
    t = clamp(t, 0.0, 1.0);
    return A + t * AB;
}

void main() {
    vec2  tx  = 1. / dimension;
    vec2  pushPoint = vec2(0.); 
    vec2  pushDir   = vec2(0.);
    float pushT     = 0.;
    float inf = 0.;
    vec2  stx = v_vTexcoord;
    vec2  p1, p2;
    
    if(usePath == 0) {
        p1 = pos1 * tx;
        p2 = pos2 * tx;
        pushDir = p2 - p1;
        
        pushPoint = closestPointOnLine(v_vTexcoord, p1, p2, pushT);
        float dis = distance(v_vTexcoord * dimension, pushPoint * dimension);
        float rad = mix(radius, radius2, pushT);
        inf = 1. - smoothstep(rad - falloff, rad + falloff, dis);
        stx -= (pushPoint - stx) * inf * intensity * pushIntens;
        stx -=  pushDir * inf * intensity * pushT;
        
    } else {
        float minDist = 9999.;
        float _intRes = intensity;
        float _pshRes = pushIntens / float(pathResolution);
        vec2 cpc;
        
        for(int i = pathResolution - 2; i >= 0; i--) {
            p1  = pathList[i]     * tx;
            p2  = pathList[i + 1] * tx;
            cpc = closestPointOnLine(stx, p1, p2, pushT);
            
            pushPoint = cpc;
            pushDir   = p2 - p1;
            
            float rad = mix(radius, radius2, (float(i) + pushT) / float(pathResolution));
            float dis = distance(stx * dimension, pushPoint * dimension);
            inf = 1. - smoothstep(rad - falloff, rad + falloff, dis);
            
            stx += (pushPoint - v_vTexcoord) * inf * _intRes * _pshRes;
            stx -=  pushDir * inf * _intRes * pushT;
        }
    }
    
    gl_FragColor = texture2Dintp( gm_BaseTexture, stx );
}
