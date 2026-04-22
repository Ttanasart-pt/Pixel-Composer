varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec4  bgColor;

uniform sampler2D bgSurface;
uniform int       useBgSurface;
uniform vec2      bgDimension;

uniform int   gridShow;
uniform float gridSize;
uniform float gridSizeMin;
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
	
	vec4 bgContent = bgColor;
	
	if(useBgSurface == 1) {
		vec2 bgTx = (v_vTexcoord * dimension) / bgDimension;
		vec4 bgSm = texture2D(bgSurface, fract(bgTx));
		bgContent = bgSm;
	}
	
	gl_FragColor = bgContent;
	if(gridShow == 0) return;
	
	vec4  res   = bgContent;
	float alpha = gridAlpha * min(1., (gridSize * graphScale) / gridSizeMin - 1.);
	
	vec2 dGrid  = mod(px,  gridSize) * graphScale;
	vec2 dGrid0 = mod(px0, gridSize) * graphScale;
	vec2 dGrid1 = mod(px1, gridSize) * graphScale;
	
	vec2 gridIndx = floor(px / gridSize);
	bool infx = dGrid0.x <= 1. && dGrid1.x > 1.;
	bool infy = dGrid0.y <= 1. && dGrid1.y > 1.;
	
	vec2 highFoc  = mod(gridIndx, gridHighlight);
	if(infx && highFoc.x == 0.) alpha += gridAlpha;
	if(infy && highFoc.y == 0.) alpha += gridAlpha;
	
	vec2 highFoc2 = mod(gridIndx, gridHighlight * gridHighlight);
	if(infx && highFoc2.x == 0.) alpha += gridAlpha;
	if(infy && highFoc2.y == 0.) alpha += gridAlpha;
	
	if(gridOrigin == 1) {
		if(infx && gridIndx.x == 0.) alpha += gridAlpha;
		if(infy && gridIndx.y == 0.) alpha += gridAlpha;
	}
	
	if(glowShow == 1) {
		float dist = distance(px, glowPos);
		float glow = clamp((glowRad - dist) / glowRad, 0., 1.);
		
		alpha += glow * .5;
	}
	
	if(infx || infy) res.rgb = mix(bgContent.rgb, gridColor.rgb, alpha);
	
	gl_FragColor = res;
}