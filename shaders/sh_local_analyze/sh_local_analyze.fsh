//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   algorithm;
uniform int   shape;
uniform float size;

uniform int sampleMode;

vec4 sampleTexture(vec2 pos) { #region
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
		
	else if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));
		
	else if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	else if(sampleMode == 3) 
		return vec4(vec3(0.), 1.);
		
	return vec4(0.);
} #endregion

float bright(in vec4 col) { return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a; }

void main() { 
	vec2 tex     = 1. / dimension;
	vec4 acc     = vec4(0.);
	vec4 maxx    = vec4(0.), minn = vec4(1.);
	float weight = 0., _w;
	vec4 col     = sampleTexture(v_vTexcoord);
	
	for(float i = -size; i <= size; i++)
	for(float j = -size; j <= size; j++) {
		if(shape == 1 && i * i + j * j > size * size) 
			continue;
		if(shape == 2 && abs(i) + abs(j) > size) 
			continue;
		
		if(shape == 0)
			_w = min(size - abs(i), size - abs(j));
		else if(shape == 1)
			_w = size - length(vec2(i, j));
		else if(shape == 2)
			_w = size - (abs(i) + abs(j));
		
		vec4 col = sampleTexture(v_vTexcoord + vec2(i, j) * tex);
		
		if(algorithm == 0) {
			acc += col;	
			weight++;
		} else if(algorithm == 1) {
			maxx = max(maxx, col);
		} else if(algorithm == 2) {
			minn = min(minn, col);
		}
	}
	
	if(algorithm == 0)
		gl_FragColor = acc / weight;
	else if(algorithm == 1)
		gl_FragColor = maxx;
	else if(algorithm == 2)
		gl_FragColor = minn;
}
