varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D textureMap;
uniform vec2 dimension;
uniform vec2 oriPosition;
uniform vec2 oriScale;
uniform int   side;

uniform int   shadowInv;
uniform float shadow;
uniform float shadowThres;

void main() {
	vec2 texPos = texture2D( textureMap, v_vTexcoord ).xy;
	vec2 oriPos = v_vTexcoord - (oriPosition / dimension);
	     oriPos /= oriScale / dimension;
	
	float shade;
	if(side == 0) {
		if(shadowInv == 0) shade = oriPos.y - shadowThres < texPos.y? shadow : 1.;
		else               shade = oriPos.y - shadowThres > texPos.y? shadow : 1.;
		
	} else {
		if(shadowInv == 0) shade = oriPos.x - shadowThres < texPos.x? shadow : 1.;
		else               shade = oriPos.x - shadowThres > texPos.x? shadow : 1.;
	}
	
	vec4  tex   = texture2D( gm_BaseTexture, v_vTexcoord );
	
	tex.rgb *= shade;
	
    gl_FragColor = tex;
}
