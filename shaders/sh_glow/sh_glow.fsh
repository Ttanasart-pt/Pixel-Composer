#define TAU 6.283185307179586

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   mode;
uniform float border;
uniform float size;
uniform float strength;
uniform vec4  color;

uniform int   blend;
uniform int   side;
uniform int   render;
uniform int   pixelDist;

float bright(in vec4 col) { return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a; }
vec4  sample(vec2    pos) { return texture2D( gm_BaseTexture, pos ); }

void main() {
	vec2 tx   = 1. / dimension;
	vec2 px   = floor(v_vTexcoord * dimension);
	vec4 base = sample(v_vTexcoord);
	
	if(render == 1) {
		gl_FragColor = base;
	} else {
		if(mode == 0) gl_FragColor = vec4(0., 0., 0., 1.);
		if(mode == 1) gl_FragColor = vec4(0., 0., 0., 0.);
	}
	
	if(side == 0) {
		if(mode == 0 && base.rgb == vec3(1.)) return;
		if(mode == 1 && base.a == 1.)         return;
		
	} else if(side == 1) {
		if(mode == 0 && base.rgb == vec3(0.)) return;
		if(mode == 1 && base.a == 0.)         return;
		
	}
	
	float dist = 0.;
	float astp = max(64., size * 4.);
	
    for(float i = 1.; i < size; i++)
	for(float j = 0.; j <= astp; j++) {
		
		float angle = j / astp * TAU;
		vec2  smPos = v_vTexcoord + vec2(cos(angle), sin(angle)) * i * tx;
		vec4  samp  = sample(smPos);
		
		vec2  samPx  = floor(smPos * dimension);
		float pxDist = distance(px, samPx);
		
		if(side == 0) {
			if((mode == 0 && bright(samp) > bright(base)) || (mode == 1 && samp.a > base.a)) {
				dist = pixelDist == 1? i : pxDist;
				i = size;
				break;
			}
			
		} else if(side == 1) {
			if((mode == 0 && bright(samp) < bright(base)) || (mode == 1 && samp.a < base.a)) {
				dist = pixelDist == 1? i : pxDist;
				i = size;
				break;
			}
		}
	}
	
	if(dist <= 0.) return;
	
	vec4  cc  = color;
	float str = (1. - dist / size) * strength;
	
	//blend
	vec4 baseColor   = base;
	vec4 targetColor = base;
	
	baseColor = render == 1? base : vec4(0.);
	
	     if(blend == 0)   targetColor = cc; // normal
	else if(blend == 1) { targetColor = cc; str = clamp(str, 0., 1.); } // replace
	// 2
	else if(blend == 3) targetColor = base + cc; // lighten
	else if(blend == 4) targetColor = 1. - (1. - base) * (1. - cc); // screen
	// 5
	else if(blend == 6) targetColor = base - cc * str; // darken
	else if(blend == 7) targetColor = base * cc; // multiply
	
	if(mode == 0) { // greyscale
		baseColor.a   = base.a;
		targetColor.a = base.a;
		
	} else if(side == 0) { // outer alpha // remove alpha multipliers
		baseColor   = vec4(cc.rgb, 0.);
		targetColor = vec4(cc.rgb, 1.);
		
	}
	
	gl_FragColor = mix(baseColor, targetColor, str);
}
