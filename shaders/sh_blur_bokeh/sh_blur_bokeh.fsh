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

uniform vec2 dimension;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

uniform float iteration;

const float phi = 2.39996323;
// const float ite = 400.0;

const float ContrastAmount = 150.0;
const vec3  ContrastFactor = vec3(9.0);
const float Smooth = 2.0;

void main() {
	float str = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = texture2D( strengthSurf, v_vTexcoord );
		str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec3 num, weight;
	
	float alpha = 0.;
    float rec   = 1.0; // reciprocal 
    vec2  hang  = vec2(0.0, str * 0.01 / sqrt(iteration));
    vec2  asp   = vec2(dimension.y / dimension.x, 1.0);
	mat2  rot   = mat2( cos(phi), sin(phi), -sin(phi), cos(phi) );

	for (float i; i < iteration; i++) {
        rec += 1.0 / rec;
	    hang = hang * rot;
        
        vec2 off = (rec - 1.0) * hang;
        vec2 suv = v_vTexcoord + asp * off;
		vec4 sam = sampleTexture(gm_BaseTexture, suv);
        vec3 col = sam.rgb * sam.a;
		vec3 bok = Smooth + pow(col, ContrastFactor) * ContrastAmount;
		
		num		+= col * bok;
		alpha	+= sam.a * (bok.r + bok.g + bok.b) / 3.;
		weight	+= bok;
	}
	
	gl_FragColor = vec4(num / weight, alpha / ((weight.r + weight.g + weight.b) / 3.));
}
