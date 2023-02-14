//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D mask;
uniform int useMask;

uniform sampler2D original;
uniform sampler2D edited;
uniform float mixRatio;

void main() {
	vec4 msk = texture2D( mask, v_vTexcoord );
	vec4 ori = texture2D( original, v_vTexcoord );
	vec4 edt = texture2D( edited, v_vTexcoord );
	
	float rat = (useMask == 1? (msk.r + msk.g + msk.b) / 3. * msk.a : 1.) * mixRatio;
	gl_FragColor = mix(ori, edt, clamp(rat, 0., 1.));
}
