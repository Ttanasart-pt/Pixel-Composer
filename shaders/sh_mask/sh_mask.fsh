varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D mask;
uniform int useMask;
uniform int invMask;

uniform sampler2D original;
uniform sampler2D edited;
uniform float mixRatio;

void main() {
	vec4 msk = texture2D( mask, v_vTexcoord );
	vec4 ori = texture2D( original, v_vTexcoord );
	vec4 edt = texture2D( edited, v_vTexcoord );
	
	float mskAmo = (msk.r + msk.g + msk.b) / 3. * msk.a;
	if(invMask == 1) mskAmo = 1. - mskAmo;
	
	float rat = (useMask == 1? mskAmo : 1.) * mixRatio;
	      rat = clamp(rat, 0., 1.);
		  
	gl_FragColor = mix(ori, edt, rat);
	if(ori.a == 0.) gl_FragColor.rgb = edt.rgb;
	if(edt.a == 0.) gl_FragColor.rgb = ori.rgb;
}
