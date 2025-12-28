varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   normal;
uniform int   swapx;
uniform int   swapy;
uniform int   ignoreBlack;

uniform vec2      height;
uniform int       heightUseSurf;
uniform sampler2D heightSurf;

uniform vec2      smooth;
uniform int       smoothUseSurf;
uniform sampler2D smoothSurf;

#define s2 1.4142135624

float bright(in vec4 col) { return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a; }

void main() {
	float hei = height.x;
	if(heightUseSurf == 1) {
		vec4 _vMap = texture2D( heightSurf, v_vTexcoord );
		hei = mix(height.x, height.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float smt = smooth.x;
	if(smoothUseSurf == 1) {
		vec4 _vMap = texture2D( smoothSurf, v_vTexcoord );
		smt = mix(smooth.x, smooth.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 tx = 1. / dimension;
    bool ig = ignoreBlack == 1;
    
	vec4  c   = texture2D(gm_BaseTexture, v_vTexcoord);
	float siz = 1. + smt;
	
    float cc = bright(c);
    if(ig && (cc == 0. || cc == 1.)) { gl_FragColor = vec4(.5, .5, 1., c.a); return; }
    
    float h0 = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2(-1.,  0.) * siz));
    float h1 = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2( 1.,  0.) * siz));
    float v0 = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2( 0., -1.) * siz));
    float v1 = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2( 0.,  1.) * siz));
    
    vec2 _n = vec2(0.);
	vec2  w = vec2(0.);
    
	/*if(!(ig && (h1 == 0. || h1 == 1.))) { */_n += vec2(h1 - cc, 0.); w.x += .5; /*}*/
	/*if(!(ig && (h0 == 0. || h0 == 1.))) { */_n += vec2(cc - h0, 0.); w.x += .5; /*}*/
	/*if(!(ig && (v1 == 0. || v1 == 1.))) { */_n += vec2(0., v1 - cc); w.y += .5; /*}*/
	/*if(!(ig && (v0 == 0. || v0 == 1.))) { */_n += vec2(0., cc - v0); w.y += .5; /*}*/
	
	if(smt > 0.) {
		float d0  = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2( 1., -1.) * siz));
	    float d1  = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2(-1., -1.) * siz));
	    float d2  = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2(-1.,  1.) * siz));
	    float d3  = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2( 1.,  1.) * siz));
    
	   	/*if(!(ig && (d0 == 0. || d0 == 1.))) { */_n += vec2(d0 - cc, cc - d0) / s2; w += .5 * s2; /*}*/
		/*if(!(ig && (d1 == 0. || d1 == 1.))) { */_n += vec2(cc - d1, cc - d1) / s2; w += .5 * s2; /*}*/
		/*if(!(ig && (d2 == 0. || d2 == 1.))) { */_n += vec2(cc - d2, d2 - cc) / s2; w += .5 * s2; /*}*/
		/*if(!(ig && (d3 == 0. || d3 == 1.))) { */_n += vec2(d3 - cc, d3 - cc) / s2; w += .5 * s2; /*}*/
		
	}
	
	if(w.x > 0.) _n.x *= hei / w.x;
	if(w.y > 0.) _n.y *= hei / w.y;
	
	if(swapx == 1) _n.x = -_n.x;
	if(swapy == 1) _n.y = -_n.y;
	
	vec3 n3 = vec3(_n, 1.);
	if(normal == 1) n3 = normalize(n3);
	
    gl_FragColor = vec4(.5 + n3 * .5, c.a);
}
