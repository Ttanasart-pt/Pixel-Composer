varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int  useMask;
uniform vec4 color;

uniform int  useFg;
uniform sampler2D fg;

void main() {
	vec4 res = color;
	     
	if(useFg == 1) {
		vec4 vfg  = texture2D( fg, v_vTexcoord);
		res  = res * (1. - vfg.a) + vfg * vfg.a;
		res.a = 1.;
	}
	     
	if(useMask == 1) {
		vec4 mask = texture2D( gm_BaseTexture, v_vTexcoord );
		float msk = (mask.r + mask.g + mask.b) / 3. * mask.a;
		res.a *= msk;
	}
	
	gl_FragColor = res;
}
