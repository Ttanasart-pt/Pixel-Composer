#pragma use(sampler_simple)

#region -- sampler_simple -- [1729740692.1417658]
    uniform int  sampleMode;
    
    vec4 sampleTexture( sampler2D texture, vec2 pos) {
        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
             if(sampleMode <= 1) return vec4(0.);
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }
#endregion -- sampler_simple --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform vec2  scale;
uniform float seed;

uniform int useSampler;

float random (in vec2 st, float seed) {
    return fract(sin(dot(st.xy + seed, vec2(1892.9898, 78.23453))) * 437.54123);
}

vec2 hexagonGetID( in vec2 p ) {
	vec2  q = vec2( p.x, p.x * 0.5 + p.y * 0.8660254037 );
	
	vec2 i = floor(q);
	vec2 f = fract(q);
	
	float v = mod(i.x + i.y, 3.);
	vec2 id = i + v;
	
	if(v == 2.) 
		id -= (f.x > f.y)? vec2(1., 2.) : vec2(2., 1.);
	
	return vec2( id.x, (2. * id.y - id.x) / 3. );
}

void main() {
	vec2 pos = (v_vTexcoord - position / dimension) * scale;
	float ratio = dimension.x / dimension.y;
	vec2 hx = hexagonGetID(pos);
	
	if(useSampler == 0) {
		float n0 = random(hx, floor(seed) / 5000.);
		float n1 = random(hx, (floor(seed) + 1.) / 5000.);
		float n  = mix(n0, n1, fract(seed));
		gl_FragColor = vec4(vec3(n), 1.0);
	} else {
		vec2 samPos = floor(hx) / scale + 0.5 / scale;
		gl_FragColor = sampleTexture( gm_BaseTexture, samPos );
	}
}
