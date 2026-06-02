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
uniform int   shape;
uniform int   iradius;
uniform int   iresolution;

uniform float intensity;
uniform float shift;

float houghtVote[1024];

#define TAU 6.28318530718

void main() {
	vec2 tx  = 1. / dimension;

    float fRes = float(iresolution);
    float fRad = float(iradius);

    for(int i = -iradius; i <= iradius; i++) 
    for(int j = -iradius; j <= iradius; j++) {
        float len = length(vec2(float(i), float(j)));

             if(shape == 1 && len > fRad) continue;
        else if(shape == 2 && (abs(float(i)) + abs(float(j)) > fRad)) continue;

        vec2 offset = vec2(float(i), float(j)) * tx;
        vec2 sampTx = v_vTexcoord + offset;

        vec4 col = sampleTexture(gm_BaseTexture, sampTx);
        float br = (col.r + col.g + col.b) / 3. * col.a;

        float angle  = atan(offset.y, offset.x);
        float radius = length(offset);
        float vote   = exp(-pow(radius / fRad, 2.0) * TAU) * br * (1. - len / fRad);

        for(int k = 0; k < iresolution; k++) {
            float t = float(k) / fRes * TAU / 2.;
            float r = float(i) * cos(t) + float(j) * sin(t);
                  r = r * .5 + .5;
                  
            int iThe = int(fract(float(k) / fRes + shift) * fRes);
            int iRad = int(r * fRes);

            int idx = iThe * iresolution + iRad;
            houghtVote[idx] += vote;
        }
    }

    float maxVote  = 0.;
    float maxTheta = 0.;
    float maxR     = 0.;
	
    for(int k = 0; k < iresolution * iresolution; k++) {
        if(houghtVote[k] > maxVote) {
            maxVote  = houghtVote[k];

            maxTheta = floor(float(k) / fRes);
            maxR     = mod(float(k), fRes);
        }
    }

    float theta = maxTheta / fRes * intensity;
    float rad   = maxR / fRes;
    
    float g = theta;
	gl_FragColor = vec4(g, g, g, 1.);
}