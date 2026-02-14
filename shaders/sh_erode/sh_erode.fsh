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

uniform vec2 dimension;
uniform int  border;
uniform int  alpha;
uniform int  mode;

uniform vec2      size;
uniform int       sizeUseSurf;
uniform sampler2D sizeSurf;

#define TAU 6.283185307179586

vec4 fillColor;

float bright(in vec4 col) { return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a; }

bool isSolid(in vec4 col) {
	if(alpha == 0 && length(col.rgb) <= 0.)  return false;
	if(alpha == 1 && col.a <= 0.)            return false;
	
	return true;
}

bool checkOffset(in bool ero, in vec2 ofs) {
	vec2 pxs = v_vTexcoord + ofs / dimension;
	vec4 sam = sampleTexture( gm_BaseTexture, pxs );
	bool sol = isSolid(sam);
	
	if(!ero && sol) fillColor = sam;
	if(ero ^^ isSolid(sam)) {
		gl_FragColor = fillColor;
		return true;
	}
	
	return false;
}

void main() {
	float siz    = size.x;
	float sizMax = abs(siz);
	
	if(sizeUseSurf == 1) {
		sizMax = max(abs(size.x), abs(size.y));
		vec4 _vMap = texture2D( sizeSurf, v_vTexcoord );
		siz = mix(size.x, size.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	bool ero = siz > 0.;
	     siz = abs(siz);
	
	vec4 bc = texture2D( gm_BaseTexture, v_vTexcoord );
	
	gl_FragColor = bc;
	if(ero ^^ isSolid(bc)) return;
	
	fillColor = ero? vec4(0., 0., 0., alpha == 0? 1. : 0.) : vec4(1., 1., 1., 1.);
	
	if(mode == 0) {
		for(float i = 1.; i <= sizMax; i++) {
			if(i > siz) break;
			
			float base = 1.;
			float top  = 0.;
			for(float j = 0.; j <= 64.; j++) {
				float ang = top / base * TAU;
				top += 2.;
				if(top >= base) {
					top   = 1.;
					base *= 2.;
				}
				
				if(checkOffset(ero, vec2(cos(ang), sin(ang)) * i))
					return;
			}
		}
		
	} else if(mode == 1) {
		for(float i = -sizMax; i <= sizMax; i++) {
			if(i < -siz) continue;
			if(i >  siz) break;
			
			for(float j = -sizMax; j <= sizMax; j++) {
				if(j < -siz) continue;
				if(j >  siz) break;
				
				if(checkOffset( ero, vec2( i,  j) )) return;
			}
		}
		
	} else if(mode == 2) {
		for(float i = -sizMax; i <= sizMax; i++) {
			if(i < -siz) continue;
			if(i >  siz) break;
			
			for(float j = -sizMax; j <= sizMax; j++) {
				if(j < -siz) continue;
				if(j >  siz) break;
				
				if(abs(i) + abs(j) > siz) continue;
				if(checkOffset( ero, vec2( i,  j) )) return;
			}
		}
		
	} else if(mode == 3) {
		for(float i = 1.; i <= sizMax; i++) { if(i > siz) break; if(checkOffset( ero, vec2( i, 0.) )) return; }
		for(float i = 1.; i <= sizMax; i++) { if(i > siz) break; if(checkOffset( ero, vec2(-i, 0.) )) return; }
		for(float i = 1.; i <= sizMax; i++) { if(i > siz) break; if(checkOffset( ero, vec2(0.,  i) )) return; }
		for(float i = 1.; i <= sizMax; i++) { if(i > siz) break; if(checkOffset( ero, vec2(0., -i) )) return; }
	}
	
}
