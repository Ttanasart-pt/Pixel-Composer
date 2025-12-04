#pragma use(sampler_simple)

#region -- sampler_simple -- [1764837291.6127295]
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
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }
    vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler_simple --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   algorithm;
uniform int   shape;
uniform float size;

float bright(in vec4 col) { return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a; }

void main() { 
	vec2 tex     = 1. / dimension;
	vec4 acc     = vec4(0.);
	vec4 maxx    = vec4(0.), minn = vec4(1.);
	float weight = 0., _w;
	vec4 col     = sampleTexture( gm_BaseTexture, v_vTexcoord );
	
	for(float i = -size; i <= size; i++)
	for(float j = -size; j <= size; j++) {
		if(shape == 1 && i * i + j * j > size * size) 
			continue;
		if(shape == 2 && abs(i) + abs(j) > size) 
			continue;
		
		if(shape == 0)
			_w = min(size - abs(i), size - abs(j));
		else if(shape == 1)
			_w = size - length(vec2(i, j));
		else if(shape == 2)
			_w = size - (abs(i) + abs(j));
		
		vec4 col = sampleTexture( gm_BaseTexture, v_vTexcoord + vec2(i, j) * tex );
		
		if(algorithm == 0) {
			acc += col;	
			weight++;
		} else if(algorithm == 1) {
			maxx = max(maxx, col);
		} else if(algorithm == 2) {
			minn = min(minn, col);
		}
	}
	
	if(algorithm == 0)
		gl_FragColor = acc / weight;
	else if(algorithm == 1)
		gl_FragColor = maxx;
	else if(algorithm == 2)
		gl_FragColor = minn;
}
