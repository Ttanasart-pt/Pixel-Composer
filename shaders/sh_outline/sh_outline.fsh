//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float borderSize;
uniform vec4  borderColor;

uniform int	  side;

uniform int	  is_aa;
uniform int	  is_blend;
uniform float blend_alpha;

uniform int outline_only;

#define TAU   6.28318

vec2 round(in vec2 v) {
	v.x = fract(v.x) > 0.5? ceil(v.x) : floor(v.x);	
	v.y = fract(v.y) > 0.5? ceil(v.y) : floor(v.y);	
	return v;
}

void main() {
	vec2 pixelPosition = v_vTexcoord * dimension;
	vec4 point = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 col;
	if(outline_only == 0) 
		col = point;
	else 
		col = vec4(0.);
	
	bool  isOutline			= false;
	float outline_alpha		= 1.;
	bool  closetCollected	= false;
	vec4  closetColor;
	
	bool isBorder = false;
	if(side == 0) 
		isBorder = point.a == 1.;
	else if(side == 1) 
		isBorder = point.a < 1.;
	
	if(isBorder) {
		if(borderSize > 0.) {
			outline_alpha = 0.;
			float tauDiv = TAU / 64.;
			for(float i = 1.; i <= 32.; i++) {
				if(i > borderSize) break;
				for(float j = 0.; j < 64.; j++) {
					float ang = j * tauDiv;
					vec2  pxs = (pixelPosition + vec2( cos(ang),  sin(ang)) * i) / dimension;
					vec4  sam = texture2D( gm_BaseTexture, pxs );
					
					if((side == 0 && sam.a < 1.) || (side == 1 && sam.a > 0.)) {
						isOutline = true;
						if(!closetCollected) {
							closetCollected = true;
							closetColor     = sam;
						}
						if(i == borderSize)
							outline_alpha += sam.a;
						else
							outline_alpha = 1.;
					}
				}
			}
		} else {
			outline_alpha = 1.;
			float tauDiv = TAU / 4.;
			for(float j = 0.; j < 4.; j++) {
				float ang = j * tauDiv;
				vec2 pxs = (pixelPosition + vec2( cos(ang),  sin(ang)) ) / dimension;
				vec4 sam = texture2D( gm_BaseTexture, pxs );
				if((side == 0 && sam.a == 0.) || (side == 1 && sam.a > 0.)) {
					isOutline = true;
					if(!closetCollected) {
						closetCollected = true;
						closetColor = sam;
					}
					break;
				}
			}
		}
		
		if(isOutline) {
			if(is_blend == 0) {
				if(side == 0) {
					col = borderColor;
					if(is_aa == 1) 
						col.a = point.a;
				} else {
					float alpha = point.a + outline_alpha * (1. - point.a);
					col = ((point * point.a) + (borderColor * outline_alpha * (1. - point.a))) / alpha;
					if(is_aa == 1) 
						col.a = alpha;
					else 
						col.a = 1.;
				}
			} else { 
				vec4 bcol;
				if(side == 0) 
					bcol = point;
				else if(side == 1)
					bcol = closetColor;
				
				float blend = blend_alpha * outline_alpha;
				if(is_aa == 0)
					blend = blend_alpha;
					
				float alpha = bcol.a + blend * (1. - bcol.a);
				col = (borderColor * blend + bcol * bcol.a * ( 1. - blend )) / alpha;
				col.a = alpha;
			}
		}
	}
	
    gl_FragColor = col;
}
