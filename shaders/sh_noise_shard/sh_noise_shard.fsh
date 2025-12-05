//Shard noise
//By ENDESGA

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;

uniform vec2      progress;
uniform int       progressUseSurf;
uniform sampler2D progressSurf;
        float     prog;
		
uniform vec2      sharpness;
uniform int       sharpnessUseSurf;
uniform sampler2D sharpnessSurf;
        float     sharp;
		
uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;
		
uniform vec2  dimension;
uniform vec2  position;
uniform float rotation;

uniform sampler2D uvMap;
uniform int   useUvMap;
uniform float uvMapMix;

#define tau 6.283185307179586

vec3 hash(vec3 p) { return fract(sin(vec3(
										dot(p, vec3(127.1324, 311.7874, 829.3683)) * (152.6178612 + seed / 10000.), 
										dot(p, vec3(269.8355, 183.3961, 614.5965)) * (437.5453123 + seed / 10000.),
										dot(p, vec3(615.2689, 264.1657, 278.1687)) * (962.6718165 + seed / 10000.)
									)) * 43758.5453); }

float shard_noise(in vec3 p, in float _sharp) {
    vec3 ip = floor(p);
    vec3 fp = fract(p);

    float v = 0., t = 0.;
	
    for (int z = -1; z <= 1; z++)
    for (int y = -1; y <= 1; y++)
    for (int x = -1; x <= 1; x++) {
        vec3 o  = vec3(x, y, z);
        vec3 io = ip + o;
        vec3 h  = hash(io);
        vec3 r  = fp - (o + h);
        float w = exp2(-tau*dot(r, r));
		
        // tanh deconstruction and optimization by @Xor
        float s = _sharp * dot(r, hash(io + vec3(11, 31, 47)) - 0.5);
        v += w * s * inversesqrt(1.0 + s * s);
        t += w;
    }
	
    return ((v / t) * .5) + .5;
}

void main() {
	#region params
		vec2 sca = scale;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
		}
		
		prog = progress.x;
		if(progressUseSurf == 1) {
			vec4 _vMap = texture2D( progressSurf, v_vTexcoord );
			prog = mix(progress.x, progress.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		sharp = sharpness.x;
		if(sharpnessUseSurf == 1) {
			vec4 _vMap = texture2D( sharpnessSurf, v_vTexcoord );
			sharp = mix(sharpness.x, sharpness.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	vec2  vtx = useUvMap == 0? v_vTexcoord : mix(v_vTexcoord, texture2D( uvMap, v_vTexcoord ).xy, uvMapMix);
	vec2  ntx = vtx * vec2(1., dimension.y / dimension.x);
	float ang = radians(rotation);
    vec2  pos = (ntx - position / dimension) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * sca / 16.;
    
	prog      /= 100.;
    vec3 uv    = vec3( pos + prog, prog * .5 );
    
    gl_FragColor = vec4( vec3(shard_noise(16.0 * uv, pow(sharp, 2.) * 20.)), 1. );
}