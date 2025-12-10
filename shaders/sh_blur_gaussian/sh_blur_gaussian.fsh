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
uniform int  horizontal;

uniform vec2      size;
uniform int       sizeUseSurf;
uniform sampler2D sizeSurf;

uniform float weight[128];
uniform float angle;

uniform int  overrideColor;
uniform vec4 overColor;

uniform int  gamma;

float wgh  = 0.;
float twgh = 0.;

vec4 sample(in vec2 pos, in float index, in float tsize) {
	float fr = fract(index);
	int   fi = int(floor(index));
	
	float wg0 = weight[fi    ];
	float wg1 = weight[fi + 1];
	float wg  = mix(wg0, wg1, fr);
	
	vec4 col = sampleTexture( gm_BaseTexture, pos, index / tsize);
	if(gamma == 1) col.rgb = pow(abs(col.rgb), vec3(2.2));
	
	col.rgb *= wg * col.a;
	wgh     += wg * col.a;
	twgh    += wg;
	
	return col;
}

void main() {
    vec2 tex_offset = 1.0 / dimension, pos;
    mat2 rot        = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
	
	float str    = size.x;
	float strMax = max(size.x, size.y);
	if(sizeUseSurf == 1) {
		vec4 _vMap = texture2D( sizeSurf, v_vTexcoord );
		str = mix(size.x, size.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	} 
	
	vec4 result = sample( v_vTexcoord, 0., str );
	
    if(horizontal == 1) {
        for(float i = 1.; i < strMax; i++) {
        	if(i > str) break;
			pos = rot * vec2(tex_offset.x * i, 0.0);
			
			float _i = i / str * strMax;
			result += sample( v_vTexcoord + pos, _i, str );
			result += sample( v_vTexcoord - pos, _i, str );
        }
    	
    } else {
        for(float i = 1.; i < strMax; i++) {
        	if(i > str) break;
			pos = rot * vec2(0.0, tex_offset.y * i);
			
			float _i = i / str * strMax;
			result += sample( v_vTexcoord + pos, _i, str );
			result += sample( v_vTexcoord - pos, _i, str );
        }
    }
	
	result.rgb /=  wgh;
	result.a    =  wgh / twgh;
	
	if(gamma == 1) result.rgb = pow(result.rgb, vec3(1. / 2.2));
	
	gl_FragColor = result;
	if(overrideColor == 1) {
		gl_FragColor.rgb = overColor.rgb;
		gl_FragColor.a  *= overColor.a;
	}
}

