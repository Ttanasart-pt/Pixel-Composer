varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int   innerUse;
uniform float innerRadius;
uniform float innerAngle;
uniform float innerDistance;
uniform vec4  innerColor;
uniform int   innerShade;

uniform int   spiralUse;
uniform float spiral;
uniform int   spiralFlip;
uniform float spiralPhase;
uniform float spiralThick;
uniform vec4  spiralColor;
uniform int   spiralShade;

uniform vec4  color;

#define TAU 6.28318530718

void main() {
	vec2 tx = v_vTexcoord;
	vec2 tn = tx - .5;
	vec4 col = color;
	vec4 spr = vec4(0.);
	
	float diss = length(tn);
	float s = step(diss, .5);
	
	if(innerUse == 1) {
		float inA = radians(innerAngle);
		vec2  inC = vec2(.5) + vec2(cos(inA), -sin(inA)) * (.5 - innerRadius / 2. * innerDistance);
		float inD = length(tx - inC);
		float inS = step(inD, innerRadius / 2.);
		
		if(innerShade == 0) {
			if(inS == 0.) col *= innerColor;
		} else if(innerShade == 1) {
			col = mix(col, col * innerColor, clamp(inD / innerRadius, 0., 1.));
		}
	}
	
	if(spiralUse == 1) {
		float dirr   = atan(tn.y, tn.x) / TAU + .5 + (spiralPhase / 360.);
		if(spiralFlip == 1) dirr = 1. - dirr;
		
		float sprDis = fract(fract(dirr) + 1.) * spiral;
		float sprThk = diss * spiralThick;
		
		if(abs(diss - sprDis) < sprThk) {
			if(spiralShade == 1)
				 col *= spiralColor;
			else col  = color * spiralColor;
			
			// col = vec4(0.);
		}
	}
	
	col.a *= s;
	gl_FragData[0] = col;
	gl_FragData[1] = spr;
}