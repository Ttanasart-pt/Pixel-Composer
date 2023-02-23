//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int filter;
uniform int sampleMode;

vec4 sampleTexture(vec2 pos) {
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
	if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));
	if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	return vec4(0.);
}

const mat3 sobel = mat3( -1., -2., -1., 
						  0.,  0.,  0., 
						  1.,  2.,  1);
	
const mat3 prewit = mat3( -1., -1., -1., 
						   0.,  0.,  0., 
						   1.,  1.,  1);

const mat3 laplac = mat3(  1.,   1.,  1.,
						   1.,  -8.,  1., 
						   1.,   1.,  1);
						   
#define TAU 6.283185307179586

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a;
}

void main() {
	vec2 texel = vec2(1.) / dimension;
	vec4 point = sampleTexture( v_vTexcoord );
	vec4 hColor = vec4(0.);
	vec4 vColor = vec4(0.);
	
	for(float i = -1.; i <= 1.; i++) {
		for(float j = -1.; j <= 1.; j++) {
			vec2 pxs = v_vTexcoord + vec2(texel.x * i, texel.y * j);
			pxs = clamp(pxs, vec2(0.), vec2(1.));
			
			int ii = int(1. + i);
			int jj = int(1. + j);
			
			if(filter == 0) {
				hColor += sampleTexture( pxs ) * sobel[jj][ii];
				vColor += sampleTexture( pxs ) * sobel[ii][jj];
			} else if(filter == 1) {
				hColor += sampleTexture( pxs ) * prewit[jj][ii];
				vColor += sampleTexture( pxs ) * prewit[ii][jj];	
			} else if(filter == 2) {
				hColor += sampleTexture( pxs ) * laplac[jj][ii];
			}
		}
	}
	
	if(filter == 2)
		gl_FragColor = vec4(vec3(hColor), point.a);
	else	
		gl_FragColor = vec4(vec3(distance(hColor, vColor)), point.a);
}
