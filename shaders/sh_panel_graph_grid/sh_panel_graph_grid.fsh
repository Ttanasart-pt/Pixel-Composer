varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec4  bgColor;

uniform int   gridShow;
uniform float gridSize;
uniform vec4  gridColor;
uniform float gridAlpha;
uniform int   gridOrigin;
uniform float gridHighlight;

uniform vec2  graphPos;
uniform float graphScale;

uniform int   glowShow;
uniform vec2  glowPos;
uniform float glowRad;

void main() {
	vec2 px  = (v_vTexcoord * dimension) / graphScale - graphPos;
	vec2 px0 = floor(v_vTexcoord * dimension) / graphScale - graphPos;
	vec2 px1 = ceil(v_vTexcoord * dimension)  / graphScale - graphPos;
	
	vec2 tx  = 1. / dimension;
	vec4 res = bgColor;
	
	gl_FragColor = res;
	if(gridShow == 0) return;
	
	float alpha = gridAlpha;
	
	vec2 dGrid  = mod(px,  gridSize) * graphScale;
	vec2 dGrid0 = mod(px0, gridSize) * graphScale;
	vec2 dGrid1 = mod(px1, gridSize) * graphScale;
	
	vec2 gridIndx = floor(px / gridSize);
	vec2 highFoc  = mod(gridIndx, gridHighlight);
	bool infx = dGrid0.x <= 1. && dGrid1.x > 1.;
	bool infy = dGrid0.y <= 1. && dGrid1.y > 1.;
	
	if(infx && highFoc.x == 0.) alpha *= 2.;
	if(infy && highFoc.y == 0.) alpha *= 2.;
	
	if(gridOrigin == 1) {
		if(infx && gridIndx.x == 0.) alpha *= 2.;
		if(infy && gridIndx.y == 0.) alpha *= 2.;
	}
	
	if(glowShow == 1) {
		float dist = distance(px, glowPos);
		float glow = clamp((glowRad - dist) / glowRad, 0., 1.);
		
		alpha += glow * .5;
	}
	
	if(infx || infy) res.rgb = mix(bgColor.rgb, gridColor.rgb, alpha);
	
	gl_FragColor = res;
}