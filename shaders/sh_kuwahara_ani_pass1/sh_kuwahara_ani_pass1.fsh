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

void main() {
	vec2 tx = 1. / dimension;
    vec2 d = tx;
	
    vec3 Sx = (
         1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-d.x, -d.y)).rgb +
         2. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-d.x,  0.0)).rgb +
         1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-d.x,  d.y)).rgb +
        -1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( d.x, -d.y)).rgb +
        -2. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( d.x,  0.0)).rgb +
        -1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( d.x,  d.y)).rgb
    ) / 4.;

    vec3 Sy = (
         1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-d.x, -d.y)).rgb +
         2. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( 0.0, -d.y)).rgb +
         1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( d.x, -d.y)).rgb +
        -1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(-d.x,  d.y)).rgb +
        -2. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( 0.0,  d.y)).rgb +
        -1. * sampleTexture(gm_BaseTexture, v_vTexcoord + vec2( d.x,  d.y)).rgb
    ) / 4.;

    
    gl_FragColor = vec4(dot(Sx, Sx), dot(Sy, Sy), dot(Sx, Sy), 1.);
}