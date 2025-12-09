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

void main() {
	vec2 tx = 1. / dimension;
    vec2 d = tx;
	
    vec3 Sx = (
         1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-d.x, -d.y), 1./4.).rgb +
         2. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-d.x,  0.0), 2./4.).rgb +
         1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-d.x,  d.y), 1./4.).rgb +
        -1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( d.x, -d.y), 1./4.).rgb +
        -2. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( d.x,  0.0), 2./4.).rgb +
        -1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( d.x,  d.y), 1./4.).rgb
    ) / 4.;

    vec3 Sy = (
         1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-d.x, -d.y), 1./4.).rgb +
         2. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( 0.0, -d.y), 2./4.).rgb +
         1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( d.x, -d.y), 1./4.).rgb +
        -1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-d.x,  d.y), 1./4.).rgb +
        -2. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( 0.0,  d.y), 2./4.).rgb +
        -1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( d.x,  d.y), 1./4.).rgb
    ) / 4.;

    
    gl_FragColor = vec4(dot(Sx, Sx), dot(Sy, Sy), dot(Sx, Sy), 1.);
}