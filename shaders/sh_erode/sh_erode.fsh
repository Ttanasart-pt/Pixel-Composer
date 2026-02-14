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

uniform vec2      size;
uniform int       sizeUseSurf;
uniform sampler2D sizeSurf;

#define TAU 6.283185307179586

float bright(in vec4 col) { return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a; }

bool isEmpty(in vec4 col) {
	if(alpha == 0 && length(col.rgb) <= 0.)  return true;
	if(alpha == 1 && col.a <= 0.)            return true;
	
	return false;
}

void main() {
	float siz    = size.x;
	float sizMax = siz;
	
	if(sizeUseSurf == 1) {
		sizMax = max(size.x, size.y);
		vec4 _vMap = texture2D( sizeSurf, v_vTexcoord );
		siz = mix(size.x, size.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	bool ero = siz > 0.;
	
	vec2 tx = 1. / dimension;
	vec2 px = v_vTexcoord * dimension;
	vec4 bc = texture2D( gm_BaseTexture, v_vTexcoord );
	
	gl_FragColor = bc;
	if( !(ero ^^ isEmpty(bc)) ) return;
	
	vec4 fill = vec4(0.);
	if(ero && alpha == 0) fill.a = 1.;
	
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
			
			vec2 pxs = (px + vec2( cos(ang) * i,  sin(ang) * i)) * tx;
			vec4 sam = sampleTexture( gm_BaseTexture, pxs );
			
			bool emp = isEmpty(sam);
			if(ero ^^ emp) {
				gl_FragColor = fill;
				break;
			}
		}
	}
}
