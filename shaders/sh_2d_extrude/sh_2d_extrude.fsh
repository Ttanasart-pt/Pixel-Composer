varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float angle;
uniform float extDistance;
uniform float shift;
uniform int   wrap;

uniform sampler2D mask;
uniform int    useMask;

void main() {
	vec2 tx  = 1. / dimension;
	vec2 shf = vec2(cos(angle), -sin(angle)) * tx;
	
	float dist = extDistance;
	if(useMask == 1) {
		vec4  mm = texture2D(mask, v_vTexcoord);	
		float ms = (mm.x + mm.y + mm.z) / 3. * mm.a;
		dist = floor(dist * ms + .5);
	}
	
	vec2 vt  = v_vTexcoord - shift * shf * dist;
	vec4 cc  = texture2D(gm_BaseTexture, vt);
	
	gl_FragColor = vec4(0.);
	if(cc.a != 0.) { gl_FragColor = vec4(-1.); return; }
	
	for(float i = 1.; i <= dist; i++) {
		vec2 px = vt - shf * i;
		if(wrap == 1) px = fract(fract(px) + 1.);
		
		vec4 sp = texture2D(gm_BaseTexture, px);
		if(sp.a != 0.) { gl_FragColor = vec4(i, px, 1.); return; }
	}
	
}