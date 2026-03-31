varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D outputSurf;
uniform sampler2D background;
uniform sampler2D canvas;

uniform int useBackground;
uniform int bgDraw;
uniform int eraser;

uniform sampler2D selSurface;
uniform sampler2D selMask;
uniform int  isSelected;
uniform vec2 selSize;
uniform vec2 selPosition;

void main() {
	vec4 og = vec4(0.);
	vec4 bg = useBackground == 1? texture2D(background, v_vTexcoord) : vec4(0.);
	vec4 drawp = texture2D(canvas, v_vTexcoord);
	vec4 res;
	
	bool sel = true;
	
	if(bgDraw == 1) {
		og = texture2D(outputSurf, v_vTexcoord);
		
		if(isSelected == 1) {
			vec2 fx  = v_vTexcoord;
			     fx -= selPosition / dimension;
			     fx /= selSize     / dimension;
		    
		    if(fx.x > 0. && fx.y > 0. && fx.x < 1. && fx.y < 1.) {
				vec4  selp = texture2D( selSurface, fx );
				vec4  mask = texture2D( selMask,    fx );
				float al   = selp.a + og.a * (1. - selp.a);
				
				if(al == 0.) og = vec4(0.);
				else {
					vec4 bl = ((selp * selp.a) + (og * og.a * (1. - selp.a))) / al;
					og = vec4(bl.rgb, al);
				}
				
				if(mask.r * mask.a <= 0.) sel = false;
				
		    } else 
		    	sel = false;
		}
	}
	
	gl_FragColor = og;
	if(!sel) return;
	
	if(eraser == 1) {
		res = mix(og, bg, drawp.a);
		
	} else {
		float al = drawp.a + og.a * (1. - drawp.a);
		if(al == 0.) res = vec4(0.);
		else {
			res   = ((drawp * drawp.a) + (og * og.a * (1. - drawp.a))) / al;
			res.a = al;
		}
	}
	
	gl_FragColor = res;
}