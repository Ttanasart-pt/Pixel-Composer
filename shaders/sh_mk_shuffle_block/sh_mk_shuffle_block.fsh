varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 block;
uniform int  index[1024];
uniform int  axis;

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
	
	vec2 tx = 1. / dimension;
	vec2 px = floor(v_vTexcoord * dimension);
	
	float blockAmo   = block.x * block.y;
	float indexAmo   = min(1024., block.x * block.y);
	
	float mBlocks    = max(1., ceil((blockAmo) / 1024.));
	float mBlockStep = floor(1024. / mBlocks);
	
	vec2 blockInd    = floor(v_vTexcoord * block);
	vec2 blockuv     = fract(v_vTexcoord * block) / block;
	
	float blockIndR  = axis == 1? blockInd.x * block.y + blockInd.y : blockInd.y * block.x + blockInd.x;
	float blockIndM  = floor(blockIndR / 1024.);
	
	float blockShift = mBlocks == 0.? 0. : float(index[int(blockIndM)]);
	int   blockIndL  = int(mod(blockIndR + blockShift, 1024.));
	
	float targeIndL  = float(index[blockIndL]);
	      targeIndL  = 1024. * blockIndM + targeIndL;
	
	vec2  targeInd   = axis == 1? vec2(floor(targeIndL / block.y), mod(targeIndL, block.y)) / block : 
	                              vec2(mod(targeIndL, block.x), floor(targeIndL / block.x)) / block;
	
	gl_FragColor = texture2D(gm_BaseTexture, targeInd + blockuv);
	gl_FragColor = vec4(targeInd, 0., 1.);
}