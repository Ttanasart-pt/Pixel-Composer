varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D original;

uniform int side;
uniform int alpha;
uniform int invert;
uniform int angle;
uniform float max_distance;

const float PI = 3.14159265358979323846;

void main() {
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	float aa = alpha == 1? texture2D( original, v_vTexcoord ).a : 1.;
	
	if(col.xy == vec2(0.)) {
		gl_FragColor = vec4(vec3(0.), aa);
		return;
	}
	
	float dist = (max_distance - distance(col.xy, v_vTexcoord)) / max_distance;
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
