// Gabor noise
// By shader god Inigo Quilez (https://iquilezles.org)
// MIT License

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;

uniform vec2      alignment;
uniform int       alignmentUseSurf;
uniform sampler2D alignmentSurf;
        float     align;

uniform vec2      sharpness;
uniform int       sharpnessUseSurf;
uniform sampler2D sharpnessSurf;
        float     sharp;

uniform vec2      rotation;
uniform int       rotationUseSurf;
uniform sampler2D rotationSurf;
        float     rot;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform vec2  u_resolution;
uniform vec2  position;
uniform float trRotation;

uniform vec2  augment;

vec2 hash(vec2 p) { return fract(sin(vec2(
										dot(p, vec2(127.1324, 311.7874)) * (152.6178612 + seed / 10000.), 
										dot(p, vec2(269.8355, 183.3961)) * (437.5453123 + seed / 10000.)
									)) * 43758.5453); }

vec3 gabor_wave(in vec2 p) { #region
    vec2  ip = floor(p);
    vec2  fp = fract(p);
    
    float fa = sharp;
	float fr = align * 6.283185;
    float rt = rot;
	
    vec3 av = vec3(0.0, 0.0, 0.0);
    vec3 at = vec3(0.0, 0.0, 0.0);
	
	for( int j = -2; j <= 2; j++ )
    for( int i = -2; i <= 2; i++ ) {		
        vec2  o = vec2( i, j );
        vec2  h = hash(ip + o);
        vec2  r = fp - (o + h);

        vec2  k = normalize(-1.0 + 2.0 * hash(ip + o + augment) );
		
        float d = dot(r, r);
        float l = dot(r, k) + rt;
        float w = exp(-fa * d);
        vec2 cs = vec2( cos(fr * l + rt), sin(fr * l + rt) );
        
        av += w * vec3(cs.x, -2.0 * fa * r * cs.x - cs.y * fr * k );
        at += w * vec3(1.0,  -2.0 * fa * r);
	}
  
    return vec3( av.x, av.yz - av.x * at.yz / at.x  ) / at.x;
} #endregion

void main() {
	#region params
		vec2 sca = scale;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
		}
		
		rot = rotation.x;
		if(rotationUseSurf == 1) {
			vec4 _vMap = texture2D( rotationSurf, v_vTexcoord );
			rot = mix(rotation.x, rotation.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		rot = radians(rot);
		
		align = alignment.x;
		if(alignmentUseSurf == 1) {
			vec4 _vMap = texture2D( alignmentSurf, v_vTexcoord );
			align = mix(alignment.x, alignment.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		sharp = sharpness.x;
		if(sharpnessUseSurf == 1) {
			vec4 _vMap = texture2D( sharpnessSurf, v_vTexcoord );
			sharp = mix(sharpness.x, sharpness.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	float r     = radians(trRotation);
	vec2 pos    = v_vTexcoord;
	     pos.x *= (u_resolution.x / u_resolution.y);
         pos    = (pos - position / u_resolution) * mat2(cos(r), -sin(r), sin(r), cos(r)) * scale;
    
	vec3 f   = gabor_wave(pos);
	vec3 col = vec3(0.5 + 0.5 * f.x);
	
    gl_FragColor = vec4( col, 1.0 );
}