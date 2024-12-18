varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 block;
uniform int  index[1024]; // yep

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
	
	vec2 tx = 1. / dimension;
	vec2 px = floor(v_vTexcoord * dimension);
	
	vec2 blockInd  = floor(v_vTexcoord * block);
	vec2 blockuv   = fract(v_vTexcoord * block) / block;
	
	float blockIndR = blockInd.y * block.x + blockInd.x;
	float blockIndM = floor(blockIndR / 1024.);
	int   blockIndL = int(mod(blockIndR, 1024.));
	
	float targeIndL = float(index[blockIndL]);
	      targeIndL = 1024. * blockIndM + mod(targeIndL + float(index[int(blockIndM)]), 1024.);
	
	vec2  targeInd  = vec2(mod(targeIndL, block.x), floor(targeIndL / block.x)) / block;
	
	gl_FragColor = texture2D(gm_BaseTexture, targeInd + blockuv);
}