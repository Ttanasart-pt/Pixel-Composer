varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586

uniform vec2  dimension;

uniform vec2      borderStart;
uniform int       borderStartUseSurf;
uniform sampler2D borderStartSurf;

uniform vec2      borderSize;
uniform int       borderSizeUseSurf;
uniform sampler2D borderSizeSurf;

uniform vec4  borderColor;
uniform int	  side;
uniform int	  crop_border;
uniform int	  is_aa;
uniform int	  is_blend;

uniform vec2      blend_alpha;
uniform int       blend_alphaUseSurf;
uniform sampler2D blend_alphaSurf;

uniform int sampleMode;
uniform int outline_only;

vec2 round(in vec2 v) { #region
	v.x = fract(v.x) > 0.5? ceil(v.x) : floor(v.x);	
	v.y = fract(v.y) > 0.5? ceil(v.y) : floor(v.y);	
	return v;
} #endregion

vec4 sampleTexture(vec2 pos) { #region
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
	if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));
	if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	return vec4(0.);
} #endregion

void main() { #region
	#region params
		float bStr = borderStart.x;
		if(borderStartUseSurf == 1) {
			vec4 _vMap = texture2D( borderStartSurf, v_vTexcoord );
			bStr = mix(borderStart.x, borderStart.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	
		float bSiz = borderSize.x;
		if(borderSizeUseSurf == 1) {
			vec4 _vMap = texture2D( borderSizeSurf, v_vTexcoord );
			bSiz = mix(borderSize.x, borderSize.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	
		float bld = blend_alpha.x;
		if(blend_alphaUseSurf == 1) {
			vec4 _vMap = texture2D( blend_alphaSurf, v_vTexcoord );
			bld = mix(blend_alpha.x, blend_alpha.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	
	#endregion
	
	vec2 pixelPosition = v_vTexcoord * dimension;
	vec4 point = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 col   = outline_only == 0? point : vec4(0.);
	
	bool  isOutline			= false;
	float outline_alpha		= 1.;
	bool  closetCollected	= false;
	vec4  closetColor;
	
	#region filter out filled ot empty pixel
		bool isBorder = false;
		if(side == 0)      isBorder = point.a > 0.;
		else if(side == 1) isBorder = point.a < 1.;
	
		if(!isBorder) {
			gl_FragColor = col;
			return;
		}
	#endregion
	
	if(bSiz + bStr > 0.) {
		outline_alpha = 0.;
		for(float i = 1.; i <= 32.; i++) {
			if(i > bStr + bSiz) break;
			
			float base = 1.;
			float top  = 0.;
			for(float j = 0.; j <= 64.; j++) {
				float ang = top / base * TAU;
				top += 2.;
				if(top >= base) {
					top = 1.;
					base *= 2.;
				}
				
				vec2 pxs = (pixelPosition + vec2( cos(ang),  sin(ang)) * i) / dimension;
				if(side == 0 && crop_border == 1 && (pxs.x < 0. || pxs.x > 1. || pxs.y < 0. || pxs.y > 1.)) continue;
				
				vec4 sam = sampleTexture( pxs );
				if(side == 0 && sam.a > 0.) continue; //inside border,  skip if current pixel is filled
				if(side == 1 && sam.a < 1.) continue; //outside border, skip if current pixel is empty
				
				if(i < bStr) {
					i = 9999.;
					break;
				}
				
				isOutline = true;
				if(!closetCollected) {
					closetCollected = true;
					closetColor     = sam;
				}
				
				if(i == bSiz) outline_alpha += sam.a;
				else		  outline_alpha = 1.;
			}
		}
	} else {
		outline_alpha = 1.;
		float tauDiv = TAU / 4.;
		for(float j = 0.; j < 4.; j++) {
			float ang = j * tauDiv;
			vec2 pxs = (pixelPosition + vec2( cos(ang),  sin(ang)) ) / dimension;
			if(side == 0 && crop_border == 1 && (pxs.x < 0. || pxs.x > 1. || pxs.y < 0. || pxs.y > 1.)) continue;
			
			vec4 sam = sampleTexture( pxs );
				
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
		
	if(!isOutline) {
		gl_FragColor = col;
		return;
	}
		
	if(is_blend == 0) {
		if(side == 0) {
			col = borderColor;
			if(is_aa == 1)
				col.a = point.a;
		} else {
			float alpha = point.a + outline_alpha * (1. - point.a);
			col = ((point * point.a) + (borderColor * outline_alpha * (1. - point.a))) / alpha;
			if(is_aa == 1) col.a = borderColor.a * alpha;
			else           col.a = borderColor.a;
		}
	} else { 
		vec4 bcol;
		     if(side == 0) bcol = point;
		else if(side == 1) bcol = closetColor;
				
		float blend = bld * outline_alpha;
		if(is_aa == 0)
			blend = bld;
					
		float alpha = bcol.a + blend * (1. - bcol.a);
		col   = (borderColor * blend + bcol * bcol.a * ( 1. - blend )) / alpha;
		col.a = borderColor.a * alpha;
	}
	
    gl_FragColor = col;
} #endregion