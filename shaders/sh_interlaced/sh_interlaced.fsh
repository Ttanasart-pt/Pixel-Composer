varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int       useSurf;
uniform sampler2D prevFrame;

uniform vec2  dimension;
uniform int   axis;
uniform int   invert;

uniform vec2      size;
uniform int       sizeUseSurf;
uniform sampler2D sizeSurf;

void main() {
	float siz = size.x;
	if(sizeUseSurf == 1) {
		vec4 _vMap = texture2D( sizeSurf, v_vTexcoord );
		siz = mix(size.x, size.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    vec2 px  = v_vTexcoord * dimension - .5;
         px /= siz;
    vec2 md = mod(px, 2.);
    
    float chk = axis == 0? md.y : md.x;
    bool intl = chk < 1.;
    if(invert == 1) intl = !intl;
        
    gl_FragColor = vec4(0.);
    
         if(intl)         gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
    else if(useSurf == 1) gl_FragColor = texture2D( prevFrame,      v_vTexcoord );
}
