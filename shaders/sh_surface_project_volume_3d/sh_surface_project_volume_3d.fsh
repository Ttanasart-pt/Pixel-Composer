#pragma use(sampler)

#region -- sampler -- [1780048120.828549]
	uniform int  interpolation;
	uniform vec2 sampleDimension;
	uniform int  sampleMode;

    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

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
	    
	    // Use 3x3 grid where each sample combines adjacent weights via bilinear
	    for(int x = -1; x <= 1; x++)
	    for(int y = -1; y <= 1; y++) {
	        // Combine weights from 2 adjacent taps in each direction
	        float wx_a = lanczosWeight(float(x * 2 - 1) - offset.x, float(LANCZOS_RADIUS));
	        float wx_b = lanczosWeight(float(x * 2    ) - offset.x, float(LANCZOS_RADIUS));
	        float wy_a = lanczosWeight(float(y * 2 - 1) - offset.y, float(LANCZOS_RADIUS));
	        float wy_b = lanczosWeight(float(y * 2    ) - offset.y, float(LANCZOS_RADIUS));
	        
	        float wx_total = wx_a + wx_b;
	        float wy_total = wy_a + wy_b;
	        float w = wx_total * wy_total;
	        
	        // Offset for bilinear interpolation between the two taps
	        vec2 samplePos = vec2(x * 2, y * 2) - vec2(.5, .5) + vec2(wx_b / wx_total, wy_b / wy_total);
	        
	        col += w * texture2D(texture, center + samplePos * tx);
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
			return texture2Dintp(texture, pos);
		
			 if(sampleMode <= 1) return vec4(0.);
		else if(sampleMode == 2) return vec4(0.,0.,0., 1.);
		else if(sampleMode == 3) return texture2Dintp(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 4) return texture2Dintp(texture, fract(pos));
		// 5
		else if(sampleMode == 6) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 7) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.,0.,0.,1.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 8) return texture2Dintp(texture, vec2(fract(pos.x), clamp(pos.y, 0., 1.)));
		// 9
		else if(sampleMode == 10) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 11) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.,0.,0.,1.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 12) return texture2Dintp(texture, vec2(clamp(pos.x, 0., 1.), fract(pos.y)));
		
		return vec4(0.);
	}
	vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

// based on IQ voxel shader
// the axis is actually wrong, but I'm too lazy so just use offseted surface

uniform sampler2D surTop;    // Front
uniform sampler2D surFront;  // Side
uniform sampler2D surSide;   // Top

#define r3 1.7320508076

uniform sampler2D texSide;
uniform int   texSide_use;

uniform vec3  angle;
uniform vec3  position;

uniform int   projection;
uniform float fov;
uniform float distant;
uniform float scale;

uniform float threshold;

uniform float density;
uniform float exponent;

uniform vec4  baseColor;
uniform vec2  level;

#region ////========== Transform ============
    mat3 rotateX(float dg) {
        float c = cos(radians(dg));
        float s = sin(radians(dg));
        return mat3(
            vec3(1, 0,  0),
            vec3(0, c, -s),
            vec3(0, s,  c)
        );
    }
    
    mat3 rotateY(float dg) {
        float c = cos(radians(dg));
        float s = sin(radians(dg));
        return mat3(
            vec3( c, 0, s),
            vec3( 0, 1, 0),
            vec3(-s, 0, c)
        );
    }
    
    mat3 rotateZ(float dg) {
        float c = cos(radians(dg));
        float s = sin(radians(dg));
        return mat3(
            vec3(c, -s, 0),
            vec3(s,  c, 0),
            vec3(0,  0, 1)
        );
    }
    
    mat3 inverse(mat3 m) {
        float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
        float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
        float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];
        
        float b01 = a22 * a11 - a12 * a21;
        float b11 = -a22 * a10 + a12 * a20;
        float b21 = a21 * a10 - a11 * a20;
        
        float det = a00 * b01 + a01 * b11 + a02 * b21;
        
        return mat3(b01, (-a22 * a01 + a02 * a21), (a12 * a01 - a02 * a11),
                  b11, (a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
                  b21, (-a21 * a00 + a01 * a20), (a11 * a00 - a01 * a10)) / det;
    }
#endregion

void main() {
	mat3 rx = rotateX(angle.x);
    mat3 ry = rotateY(angle.y);
    mat3 rz = rotateZ(angle.z);
    mat3 rotMatrix  = rx * ry * rz;
    mat3 irotMatrix = inverse(rotMatrix);
	
	vec2 uv = v_vTexcoord - .5;
	vec3 dir, eye;
	
	if(projection == 0) {
		float dz  = 1. / tan(radians(fov) / 2.);
		
		dir = vec3(uv * 2., -dz);
		eye = vec3(0., 0., sqrt(3.) * distant);
			
	} else if(projection == 1) {
		dir = vec3(0., 0., -1.);
    	eye = vec3(uv * scale, sqrt(3.));
	}
	
	eye -= position;
	
	dir = irotMatrix * dir;
	dir = normalize(dir);
	eye = irotMatrix * eye;
	
	float size    = max(dimension.x, dimension.y);
	float voxSize = 2.0 / size;
    
    if(abs(dir.x) < .001) dir.x = .001; // prevent divided by zero. TODO: implement proper code when dealing with 2d projection
    if(abs(dir.y) < .001) dir.y = .001;
    if(abs(dir.z) < .001) dir.z = .001;
	
    vec3 ro  = eye / voxSize;
    vec3 rd  = dir;
    vec3 pos = floor(ro);
    vec3 ri  = 1.0 / rd;
    vec3 rs  = sign(rd);
    vec3 dis = (pos - ro + 0.5 + rs * 0.5) * ri;
    
	vec4 samTop   = vec4(0.);
	vec4 samFront = vec4(0.);
	vec4 samSide  = vec4(0.);
    vec3 mm  = vec3(0.);
	
	float volume    = 0.;
	float distn     = 0.;
	vec3  vCol      = vec3(0.);
	vec3  impactPos = vec3(0.);
	float impactDis = 0.;
	
	float normDensity = density / (size * size * size);
	
	float transmit  = 1.0;
	float maxVoxels = sqrt(3.) * size * 2.;
	if(projection == 0) maxVoxels *= distant;
	
    for (float i = 0.; i < maxVoxels; i++) {
        vec3 wc = (pos + 0.5) * voxSize;
        vec3 sc = wc * .5 + .5;
        
        if (sc.x >= 0. && sc.x < 1. && sc.y >= 0. && sc.y < 1. && sc.z >= 0. && sc.z < 1.) {
            samTop   = texture2D(surTop,   vec2(   sc.x, sc.y));
            samFront = texture2D(surFront, vec2(1.-sc.z, sc.y));
            samSide  = texture2D(surSide,  vec2(   sc.x, sc.z));
            
            float dens = ( samTop.r   + samTop.g   + samTop.b   ) * 
                         ( samFront.r + samFront.g + samFront.b ) * 
                         ( samSide.r  + samSide.g  + samSide.b  ) * 
                           samTop.a * samFront.a * samSide.a;
            
            dens = pow(dens, exponent) * normDensity;
            
            volume += dens;
            vCol   += dens;
            
            vec3 faceColor = mm.z > 0.5 ? samTop.rgb
                           : mm.x > 0.5 ? samFront.rgb
                           :              samSide.rgb;
	
	        float stepAlpha = 1.0 - exp(-dens);
			
	        vCol     += transmit * stepAlpha * faceColor;
	        transmit *= (1.0 - stepAlpha);
	
	        if (transmit > threshold) {
	        	impactPos = sc;
            	impactDis = 1. - (distance(eye, wc) / r3);
	        }
	        
	        if (transmit < .001) break;
        }
        
        mm   = step(dis.xyz, dis.yzx) * step(dis.xyz, dis.zxy);
        dis += mm * rs * ri;
        pos += mm * rs;
    }
	
    vec3 fmini  = (pos - ro + 0.5 - 0.5 * vec3(rs)) * ri;
    float ft    = max(fmini.x, max(fmini.y, fmini.z));
    vec3 hitPos = (ro + rd * ft) * voxSize;
    vec3 samPos = hitPos * .5 + .5;
    
    volume = (volume - level.x) / (level.y - level.x);
    
    // vec3 vcol = vec3(1.);
    //      if (mm.z > 0.5) vCol = vec3(1., 0., 0.);
    // else if (mm.x > 0.5) vCol = vec3(0., 1., 0.);
    // else                 vCol = vec3(0., 0., 1.);
    
    vec4 colr = baseColor;
    
    if(texSide_use == 1)
    	colr *= texture2D(texSide, vec2( impactPos.x, impactPos.y));
    
    gl_FragColor = vec4(vCol * impactDis, volume) * colr;
    // gl_FragColor = vec4(impactPos, volume);
    
    
}