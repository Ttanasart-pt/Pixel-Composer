varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D outputSurf;
uniform sampler2D background;
uniform sampler2D canvas;

uniform int bgDraw;
uniform int eraser;

uniform sampler2D selSurface;
uniform sampler2D selMask;
uniform int  isSelected;
uniform vec2 selSize;
uniform vec2 selPosition;

void main() {
	vec4 og = vec4(0.);
	vec4 bg = texture2D(background, v_vTexcoord);
	vec4 fg = texture2D(canvas,     v_vTexcoord);
	vec4 res;
	
	bool sel = true;
	
	if(bgDraw == 1) {
		og = texture2D(outputSurf, v_vTexcoord);
		
		if(isSelected == 1) {
			vec2 fx  = v_vTexcoord;
			     fx -= selPosition / dimension;
			     fx /= selSize     / dimension;
		    
		    if(fx.x > 0. && fx.y > 0. && fx.x < 1. && fx.y < 1.) {
				vec4  cFg = texture2D( selSurface, fx );
				vec4  msk = texture2D( selMask,    fx );
				float al  = cFg.a + og.a * (1. - cFg.a);
				
				og   = ((cFg * cFg.a) + (og * og.a * (1. - cFg.a))) / al;
				og.a = al;
				
				if(msk.r * msk.a <= 0.) sel = false;
				
		    } else 
		    	sel = false;
		}
	}
	
	if(!sel) {
		gl_FragColor = og;
		return;
	}
	
	if(eraser == 1) {
		res = mix(og, bg, fg.a);
		
	} else {
		float al = fg.a + og.a * (1. - fg.a);
		res = ((fg * fg.a) + (og * og.a * (1. - fg.a))) / al;
	}
	
	gl_FragColor = res;
}