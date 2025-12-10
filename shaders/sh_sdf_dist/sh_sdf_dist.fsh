varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D original;

uniform int side;
uniform int alpha;
uniform int invert;
uniform int angle;

uniform vec2      max_distance;
uniform int       max_distanceUseSurf;
uniform sampler2D max_distanceSurf;

const float PI = 3.14159265358979323846;

void main() {
	float mxd = max_distance.x;
	if(max_distanceUseSurf == 1) {
		vec4 _vMap = texture2D( max_distanceSurf, v_vTexcoord );
		mxd = mix(max_distance.x, max_distance.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	float aa = alpha == 1? texture2D( original, v_vTexcoord ).a : 1.;
	
	if(col.xy == vec2(0.)) {
		gl_FragColor = vec4(vec3(0.), aa);
		return;
	}
	
	float dist = (mxd - distance(col.xy, v_vTexcoord)) / mxd;
	if(invert == 1) dist = 1. - dist;
	
	if((side == 0 && col.z == 0.) || (side == 1 && col.z == 1.)) {
		gl_FragColor = vec4(vec3(col.z), aa);
		return;
	}
	
	vec3 cc = vec3(dist);
    
    if(angle == 1) {
	    vec2  vct = col.xy - v_vTexcoord;
	    float ang = atan(vct.y, vct.x) / PI * .5 + .5;
	    cc = vec3(ang) * step(.1, dist);
	    // cc = vec3(abs(vct) * 8., 0.) * step(.1, dist);
    }
    
    gl_FragColor = vec4(cc, aa);
}
