varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform int   side;
uniform float thickness;
uniform vec4  color;
uniform float opacity;

#define TAU 6.283185307179586

vec4 blndColor;
bool isBase(vec4 c) { return side == 1? c.a > 0. : c.a < 1.; }

bool checkPixel(vec2 shf) {
	vec4 sampColor = texture2D(gm_BaseTexture, v_vTexcoord + shf);
	bool isOutline = isBase(sampColor);
			
	if(isOutline) {
		if(side == 1) blndColor = sampColor;
		gl_FragColor = mix(blndColor, color, opacity);
	}
	
	return isOutline;
}

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 baseColor = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor   = baseColor * v_vColour;
	blndColor      = baseColor;
	
	if(isBase(baseColor)) return;
	
	if(thickness == 0.) {
		checkPixel(vec2(  tx.x, 0. ));
		checkPixel(vec2( -tx.x, 0. ));
		checkPixel(vec2( 0.,  tx.y ));
		checkPixel(vec2( 0., -tx.y ));
		return;
	}
	
	float atr = 64.;
	for(float i = 1.; i <= thickness; i++) {
		float base = 1.;
		float top  = 0.;
		
		for(float j = 0.; j <= atr; j++) {
			float ang = top / base * TAU;
			top += 2.;
			if(top >= base) {
				top   = 1.;
				base *= 2.;
			}
			
			vec2 txs = vec2(cos(ang), sin(ang)) * i * tx;
			if(checkPixel(txs)) return;
		}
	}
	
}