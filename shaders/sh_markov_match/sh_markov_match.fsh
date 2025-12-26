varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 matchDimension;

uniform vec4 matchGroup[256];
uniform int  matchGroupCount;

uniform sampler2D matchSurface;

uniform float seed;
uniform float threshold;
uniform int   boundary;
uniform int   transforms;

uniform int   tiling;
uniform vec2  tileOffset;
uniform vec2  tileSize;

uniform vec2      matchChance;
uniform int       matchChanceUseSurf;
uniform sampler2D matchChanceSurf;

#define s3 1.7320508076

float random(in vec2 st, float seed) { return fract(sin(dot(st.xy + seed / 1000., vec2(853.98598, 78.2345543))) * 47.687523); }

float matchTexture(int ori) {
	vec2  px    = v_vTexcoord * dimension;
	vec2  offs  = (matchDimension - 1.) / 2.;
	
	for(int y = 0; y < int(matchDimension.y); y++)
	for(int x = 0; x < int(matchDimension.x); x++) {
		vec2 matchPx  = vec2(float(x), float(y)) + .5;
		vec4 matchCol = texture2D(matchSurface, matchPx / matchDimension);
		if(matchCol.a == 0.) continue;
		
		vec2 basePx = px;
		     if(ori == 0) basePx += vec2( float(x),  float(y));
		else if(ori == 1) basePx += vec2( float(y), -float(x));
		else if(ori == 2) basePx += vec2(-float(x), -float(y));
		else if(ori == 3) basePx += vec2(-float(y),  float(x));
		
		if(basePx.x <= 0. || basePx.y <= 0. || basePx.x >= dimension.x || basePx.y >= dimension.y) {
			if(boundary == 0)
				continue;
				
			else if(boundary == 1)
				return 0.;
				
			else if(boundary == 2)
				basePx = clamp(basePx, vec2(.5), dimension - .5);
			
		}
		
		vec4 baseCol = texture2D(gm_BaseTexture, basePx / dimension);
		if(matchCol.rgb == matchGroup[0].rgb) {
			float thrMin = 999999.;
			for(int i = 0; i < matchGroupCount; i++)
				thrMin = min(thrMin, distance(matchGroup[i].rgb, baseCol.rgb) / s3);
			
			if(thrMin > threshold)
				return 0.;
			
		} else {
			if(distance(matchCol.rgb, baseCol.rgb) / s3 > threshold) 
				return 0.;
		}
	}
	
	return 1.;
}

void main() {
	float chn = matchChance.x;
	if(matchChanceUseSurf == 1) {
		vec4 _vMap = texture2D( matchChanceSurf, v_vTexcoord );
		chn = mix(matchChance.x, matchChance.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	gl_FragColor = vec4(0.);
	if(random(v_vTexcoord, seed) > chn) return;
	
	vec2 px = floor(v_vTexcoord * dimension);
	
	if(tiling == 1) {
		vec2 tile = mod(px - tileOffset, matchDimension);
		if(tile.x != 0. || tile.y != 0.) return;
		
	} else if(tiling == 2) {
		vec2 tile = mod(px - tileOffset, tileSize);
		if(tile.x != 0. || tile.y != 0.) return;
	}
	
	float matchOri = 0.;
	if(transforms == 0) {
		matchOri += 1. * matchTexture(0);
		
	} else if(transforms == 1) {
		int side = int(floor(4. * random(v_vTexcoord, seed + 86.5413)));
		matchOri += pow(2., + float(side)) * matchTexture(side);
		
	} else if(transforms == 2) {
		matchOri += 1. * matchTexture(0);
		matchOri += 2. * matchTexture(1);
		matchOri += 4. * matchTexture(2);
		matchOri += 8. * matchTexture(3);
	}
	
	gl_FragColor = vec4(matchOri / 255.);
}