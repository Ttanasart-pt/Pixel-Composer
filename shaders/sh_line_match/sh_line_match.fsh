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
uniform int   iradius;
uniform int   fade;
uniform int   oneSide;

uniform float intensity;
uniform vec4  color;

#define TAU 6.28318530718

void main() {
	vec2 tx = 1. / dimension;
	
	float radius = float(iradius);
	float aCount = 64.;
	float aStep  = TAU / aCount;

	float maxAngle = 0.;
	float maxWeigh = 0.;
	
	for(float a = 0.; a < TAU; a += aStep) {
		vec2  offset = vec2(cos(a), sin(a)) * tx;
		vec2  posStr = v_vTexcoord;
		float weigh  = 0.;
		
		if(oneSide == 1) {
			posStr += offset * radius;
			offset /= 2.;
		}
		
		for(float r = -radius; r <= radius; r++) {
			vec4  sam = sampleTexture(gm_BaseTexture, posStr + offset * r);
			float wgh = sam.r * sam.a;
			weigh += wgh;
		}
		
		if(weigh > maxWeigh) {
			maxWeigh = weigh;
			maxAngle = a;
		}
	}
	
	float aa = maxAngle / TAU;
	aa *= intensity;
	
	vec3 clr = color.rgb * aa;
	if(fade == 1) clr *= maxWeigh / (radius * 2. + 1.);
	
	gl_FragColor = vec4(clr, 1.);
}