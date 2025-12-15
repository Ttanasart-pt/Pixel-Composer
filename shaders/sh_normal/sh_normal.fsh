varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   normal;
uniform int   swapx;

uniform vec2      height;
uniform int       heightUseSurf;
uniform sampler2D heightSurf;

uniform vec2      smooth;
uniform int       smoothUseSurf;
uniform sampler2D smoothSurf;

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
    
	vec4  c   = texture2D(gm_BaseTexture, v_vTexcoord);
	float siz = 1. + smt;
	
    float col = bright(c);
    float h0  = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2(-1.,  0.) * siz));
    float h1  = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2( 1.,  0.) * siz));
    float v0  = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2( 0., -1.) * siz));
    float v1  = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2( 0.,  1.) * siz));
    
	vec2 _n;
	
	if(smt > 0.) {
		float d0  = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2( 1., -1.) * siz));
	    float d1  = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2(-1., -1.) * siz));
	    float d2  = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2(-1.,  1.) * siz));
	    float d3  = bright(texture2D(gm_BaseTexture, v_vTexcoord + tx * vec2( 1.,  1.) * siz));
    
	   	_n = (vec2(h1 - col, 0.)
			+ vec2(col - h0, 0.)
			+ vec2(0., v1 - col)
			+ vec2(0., col - v0)
			+ vec2(d0 - col, col - d0) / sqrt(2.)
			+ vec2(col - d1, col - d1) / sqrt(2.)
			+ vec2(col - d2, d2 - col) / sqrt(2.)
			+ vec2(d3 - col, d3 - col) / sqrt(2.)
			) / (2. + 2. * sqrt(2.));
				 
	} else {
		_n = (vec2(h1 - col, 0.)
			+ vec2(col - h0, 0.)
			+ vec2(0., v1 - col)
			+ vec2(0., col - v0)
			) / 2.;
	}
	
	if(swapx == 1) _n.x = -_n.x;
	_n  = _n * hei;
	
	vec3 n3 = vec3(_n, 1.);
	if(normal == 1) n3 = normalize(n3);
	
    gl_FragColor = vec4(.5 + n3 * .5, c.a);
}
