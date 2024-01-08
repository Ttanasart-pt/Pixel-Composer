//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float size;
uniform vec2 dimension;

uniform int useMask;
uniform sampler2D mask;
uniform int sampleMode;

uniform int overrideColor;
uniform vec4 overColor;

float sampleMask() {
	if(useMask == 0) return 1.;
	vec4 m = texture2D( mask, v_vTexcoord );
	return (m.r + m.g + m.b) / 3. * m.a;
}

vec4 sampleTexture(vec2 pos) {
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
	if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));
	if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	return vec4(0.);
}

void main() {
	vec4 clr = vec4(0.);
	float totalWeight = 0.;
	vec2 texel = 1. / dimension;
	float realSize = size;
	
	realSize *= sampleMask();
	
	if(realSize < 1.) {
		gl_FragColor = sampleTexture( v_vTexcoord );
		return;
	} else if(realSize < 2.)
		realSize = 1.;
		
	float cel  = ceil(realSize);
	float frac = fract(realSize);
	
	for( float i = -cel; i <= cel; i++ )
	for( float j = -cel; j <= cel; j++ ) {
		if(i + j >= cel * 2.) continue;
		
		vec4 sam = sampleTexture( v_vTexcoord + vec2(i, j) * texel );
		float wei = 1. - (abs(i) + abs(j)) / (realSize * 2.);
		wei *= clamp(abs(i + j - floor(realSize) * 2.), 0., 1.);
		
		totalWeight += wei;
		
		clr += sam * wei;
	}
	
	clr /= totalWeight;
	
    gl_FragColor = clr;
	if(overrideColor == 1) {
		gl_FragColor.rgb = overColor.rgb;
		gl_FragColor.a  *= overColor.a;
	}
}
