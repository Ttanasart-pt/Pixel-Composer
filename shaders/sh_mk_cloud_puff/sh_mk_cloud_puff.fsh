varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int   shape;
uniform vec2  scale;
uniform vec4  color;

uniform int   innerUse;
uniform float innerRadius;
uniform float innerAngle;
uniform float innerDistance;

uniform int   innerBlend;
uniform vec4  innerColor;
uniform int   innerShade;

uniform int   spiralUse;
uniform float spiral;
uniform int   spiralFlip;
uniform float spiralPhase;
uniform float spiralThick;

uniform int   spiralBlend;
uniform vec4  spiralColor;
uniform int   spiralShade;

#define TAU 6.28318530718

void main() {
	vec2 tx = v_vTexcoord;
	vec2 tn = (tx - .5) / scale;
	vec4 col = color;
	vec4 spr = vec4(0.);
	
	float diss, alp = 1.;
	
	if(shape == 0) {
		diss = length(tn);
		alp  = step(diss, .5);
		
	} else if(shape == 1) {
		diss = max(abs(tn.x), abs(tn.y));
		
	} else if(shape == 2) {
		diss = abs(tn.x) + abs(tn.y);
		alp  = step(diss, .5);
		
	} else if(shape == 3) {
		diss = pow(abs(tn.x * 1.5), 1./2.) + pow(abs(tn.y * 1.5), 1./2.);
		alp  = step(diss, 1.);
	}
	
	if(innerUse == 1) {
		float inA = radians(innerAngle);
		float inD, inS;
		
		vec2  inC  = vec2(.5) + vec2(cos(inA), -sin(inA)) * (.5 - innerRadius / 2. * innerDistance);
		vec2 invec = tx - inC;
		
		     if(shape == 0) inD = length(invec);
		else if(shape == 1) inD = max(abs(invec.x), abs(invec.y)); 
		else if(shape == 2) inD = abs(invec.x) + abs(invec.y); 
		else if(shape == 3) inD = pow(abs(invec.x * 1.5), 1./2.) + pow(abs(invec.y * 1.5), 1./2.);
		
		inS = step(inD, innerRadius / 2.);
		
		vec4 blndC = col * innerColor;
		
		     if(innerBlend == 0) blndC = innerColor;
		else if(innerBlend == 1) blndC = col * innerColor;
		else if(innerBlend == 2) blndC = col + innerColor;
		else if(innerBlend == 3) blndC.rgb = col.rgb - innerColor.rgb;
			
		if(innerShade == 0 && inS == 0.)
			col = blndC;
		else if(innerShade == 1)
			col = mix(col, blndC, clamp(inD / innerRadius, 0., 1.));
	}
	
	if(spiralUse == 1) {
		float dirr   = atan(tn.y, tn.x) / TAU + .5 + (spiralPhase / 360.);
		if(spiralFlip == 1) dirr = 1. - dirr;
		
		float sprDis = fract(fract(dirr) + 1.) * spiral;
		float sprThk = diss * spiralThick;
		
		if(abs(diss - sprDis) < sprThk) {
			vec4 baseC = spiralShade == 0? color : col;
			
			     if(spiralBlend == 0) col = spiralColor;
			else if(spiralBlend == 1) col = baseC * spiralColor;
			else if(spiralBlend == 2) col = baseC + spiralColor;
			else if(spiralBlend == 3) col = baseC - spiralColor;
			
		}
	}
	
	col.a *= alp;
	gl_FragData[0] = col;
	gl_FragData[1] = spr;
}