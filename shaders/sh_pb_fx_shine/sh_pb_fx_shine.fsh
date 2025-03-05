varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   useMask;
uniform sampler2D mask;

uniform float progress;
uniform int   side;
uniform float shines[64];
uniform float shinesWidth; 
uniform int   shineAmount; 
uniform vec4  shineColor;

uniform float slope; 
uniform float intensity; 

void main() {
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = cc;
	
	if(cc.a == 0.) return;
	if(useMask == 1) {
		vec4 mm = texture2D(mask, v_vTexcoord);
		if((mm.r + mm.g + mm.b) * mm.a == 0.) return;
	}
	
	vec2  px = floor(v_vTexcoord * dimension);
	float tw = dimension.x + shinesWidth;
	
	float ns = mix(-dimension.x - tw, dimension.x + tw, progress);
	float dy = px.y / slope;
	
	if(side == 1) ns = ns + dy;
	else          ns = ns + dimension.x - dy;
	
	float os = ns;
	bool  fill = true;
	
	for(int i = 0; i < shineAmount; i++) {
		float _shine = shines[i];
		ns += _shine;
		
		if(fill && px.x > os && px.x <= ns) {
			cc = mix(cc, shineColor, intensity);
			break;
		}
		
		fill = !fill;
		os   = ns;
	}
	
	gl_FragColor = cc;
}