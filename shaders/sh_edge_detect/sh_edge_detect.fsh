//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int filter;

const mat3 sobel = mat3( -1., -2., -1., 
						  0.,  0.,  0., 
						  1.,  2.,  1);
	
const mat3 prewit = mat3( -1., -1., -1., 
						   0.,  0.,  0., 
						   1.,  1.,  1);

const mat3 laplac = mat3(  1.,   1.,  1., 
						   1.,  -8.,  1., 
						   1.,   1.,  1);
						   
#define TAU  6.28318

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a;
}

void main() {
	vec2 texel = vec2(1.) / dimension;
	vec4 point = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 hColor = vec4(0.);
	vec4 vColor = vec4(0.);
	
	for(float i = -1.; i <= 1.; i++) {
		for(float j = -1.; j <= 1.; j++) {
			vec2 pxs = v_vTexcoord + vec2(texel.x * i, texel.y * j);
			pxs = clamp(pxs, vec2(0.), vec2(1.));
			
			int ii = int(1. + i);
			int jj = int(1. + j);
			
			if(filter == 0) {
				hColor += texture2D( gm_BaseTexture, pxs ) * sobel[jj][ii];
				vColor += texture2D( gm_BaseTexture, pxs ) * sobel[ii][jj];
			} else if(filter == 1) {
				hColor += texture2D( gm_BaseTexture, pxs ) * prewit[jj][ii];
				vColor += texture2D( gm_BaseTexture, pxs ) * prewit[ii][jj];	
			} else if(filter == 2) {
				hColor += texture2D( gm_BaseTexture, pxs ) * laplac[jj][ii];
			}
		}
	}
	
	if(filter == 2)
		gl_FragColor = vec4(vec3(hColor), point.a);
	else	
		gl_FragColor = vec4(vec3(distance(hColor, vColor)), point.a);
}
