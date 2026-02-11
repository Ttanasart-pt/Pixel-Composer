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

uniform sampler2D surface1;
uniform sampler2D surface2;

uniform vec2  dimension;
uniform float factor;

uniform vec2      radius;
uniform int       radiusUseSurf;
uniform sampler2D radiusSurf;

void main() {
	float rad    = radius.x;
	float radMax = max(radius.x, radius.y);
	if(radiusUseSurf == 1) {
		vec4 _vMap = texture2D( radiusSurf, v_vTexcoord );
		rad = mix(radius.x, radius.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 tx = 1. / dimension;
	
	vec4 col1 = sampleTexture(surface1, v_vTexcoord);
	vec4 col2 = sampleTexture(surface2, v_vTexcoord);
	
	gl_FragColor = vec4(0.);
	
	if(col1.r * col1.a > 0.) { gl_FragColor = col1; return; }
	if(col2.r * col2.a > 0.) { gl_FragColor = col2; return; }
	
	float minD1 = 999999.;
	float minD2 = 999999.;
	
	vec4 colw1;
	vec4 colw2;
	
	for(float i = -radMax; i <= radMax; i++)
	for(float j = -radMax; j <= radMax; j++) {
		vec2 shft   = vec2(i, j);
		vec2 sampTx = v_vTexcoord + shft * tx;
		float d = length(shft);
		if(d > rad) continue;
		
		vec4 c1 = sampleTexture(surface1, sampTx);
		vec4 c2 = sampleTexture(surface2, sampTx);
		
		if(c1.r * c1.a > 0. && d < minD1) { minD1 = d; colw1 = c1; }
		if(c2.r * c2.a > 0. && d < minD2) { minD2 = d; colw2 = c2; }
	}
	
	float mrad = rad;
	float fact = 1. / factor;
	
	float w1 = pow(minD1, fact);
	float w2 = pow(minD2, fact);
	float wr = pow(mrad,  fact);
	
	bool weld = w1 + w2 < wr;
	
	if(weld) {
		float mixx = (minD1) / max(minD1 + minD2, 0.00001);
		
		gl_FragColor = mix(colw1, colw2, mixx);
	}
}