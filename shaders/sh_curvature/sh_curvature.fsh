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

uniform vec2      intensity;
uniform int       intensityUseSurf;
uniform sampler2D intensitySurf;

uniform vec2      radius;
uniform int       radiusUseSurf;
uniform sampler2D radiusSurf;

uniform int absolute;

float sampleG( sampler2D texture, vec2 pos) {
    vec4 col = sampleTexture(texture, pos);
    return (col.r + col.g + col.b) / 3. * col.a;
}

void main() {
	float rad    = radius.x;
	float radMax = floor(max(radius.x, radius.y));
	if(radiusUseSurf == 1) {
		vec4 _vMap = texture2D( radiusSurf, v_vTexcoord );
		rad = mix(radius.x, radius.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float itn    = intensity.x;
	if(intensityUseSurf == 1) {
		vec4 _vMap = texture2D( intensitySurf, v_vTexcoord );
		itn = mix(intensity.x, intensity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    vec2 tx = 1. / dimension;
    vec2 uv = getUV(v_vTexcoord);
	
    vec2 offset = rad * tx;
    
    float c = sampleG(gm_BaseTexture, uv);
    float l = sampleG(gm_BaseTexture, uv + vec2(-offset.x, 0.0));
    float r = sampleG(gm_BaseTexture, uv + vec2( offset.x, 0.0));
    float t = sampleG(gm_BaseTexture, uv + vec2(0.0,  offset.y));
    float b = sampleG(gm_BaseTexture, uv + vec2(0.0, -offset.y));
    
    float tl = sampleG(gm_BaseTexture, uv + vec2(-offset.x,  offset.y));
    float tr = sampleG(gm_BaseTexture, uv + vec2( offset.x,  offset.y));
    float bl = sampleG(gm_BaseTexture, uv + vec2(-offset.x, -offset.y));
    float br = sampleG(gm_BaseTexture, uv + vec2( offset.x, -offset.y));
    
    float dxx = (r - 2.0 * c + l) / (rad * rad);
    float dyy = (t - 2.0 * c + b) / (rad * rad);
    
    float d1 = (tr - 2.0 * c + bl) / (rad * rad * 2.0);
    float d2 = (tl - 2.0 * c + br) / (rad * rad * 2.0);
    
    if(absolute == 1) {
    	dxx = abs(dxx);
		dyy = abs(dyy);
		d1  = abs(d1);
		d2  = abs(d2);
    }
    
    float curv = (dxx + dyy + d1 + d2) * 0.5;
    float grey = .5 + .5 * curv * itn;
    
	gl_FragColor = vec4(vec3(grey), 1.0);
}