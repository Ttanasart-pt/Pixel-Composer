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

const mat3 laplac_r0  = mat3(  0.,   1.,  0.,
					     	   0.,  -1.,  0., 
					     	   0.,   0.,  0);

const mat3 laplac_r1  = mat3(  0.,   0.,  0.,
					     	   0.,  -1.,  1., 
					     	   0.,   0.,  0);

const mat3 laplac_r2  = mat3(  0.,   0.,  0.,
					     	   0.,  -1.,  0., 
					     	   0.,   1.,  0);

const mat3 laplac_r3  = mat3(  0.,   0.,  0.,
					     	   1.,  -1.,  0., 
					     	   0.,   0.,  0);

const mat3 laplac_r4  = mat3(  1.,   0.,  0.,
					     	   0.,  -1.,  0., 
					     	   0.,   0.,  0);

const mat3 laplac_r5  = mat3(  0.,   0.,  1.,
					     	   0.,  -1.,  0., 
					     	   0.,   0.,  0);

const mat3 laplac_r6  = mat3(  0.,   0.,  0.,
					     	   0.,  -1.,  0., 
					     	   0.,   0.,  1);

const mat3 laplac_r7  = mat3(  0.,   0.,  0.,
					     	   0.,  -1.,  0., 
					     	   1.,   0.,  0);
						   
#define TAU 6.283185307179586

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a;
}

void main() {
	vec2 texel = vec2(1.) / dimension;
	vec4 point = sampleTexture( v_vTexcoord );
	vec4 hColor = vec4(0.);
	vec4 vColor = vec4(0.);
	
	if(filter == 3) {
		vec4 hColor0 = vec4(0.);
		vec4 hColor1 = vec4(0.);
		vec4 hColor2 = vec4(0.);
		vec4 hColor3 = vec4(0.);
		vec4 hColor4 = vec4(0.);
		vec4 hColor5 = vec4(0.);
		vec4 hColor6 = vec4(0.);
		vec4 hColor7 = vec4(0.);
		
		for(float i = -1.; i <= 1.; i++) 
		for(float j = -1.; j <= 1.; j++) {
			vec2 pxs = v_vTexcoord + vec2(texel.x * i, texel.y * j);
			pxs = clamp(pxs, vec2(0.), vec2(1.));
			
			int ii = int(1. + i);
			int jj = int(1. + j);
			vec4 sam = sampleTexture( pxs );
			
			hColor0 += sam * laplac_r0[jj][ii];
			//hColor1 += sam * laplac_r1[jj][ii];
			//hColor2 += sam * laplac_r2[jj][ii];
			hColor3 += sam * laplac_r3[jj][ii];
			hColor4 += sam * laplac_r4[jj][ii];
			//hColor5 += sam * laplac_r5[jj][ii];
			//hColor6 += sam * laplac_r6[jj][ii];
			//hColor7 += sam * laplac_r7[jj][ii];
		}
		
		hColor0 = abs(hColor0);
		hColor1 = abs(hColor1);
		hColor2 = abs(hColor2);
		hColor3 = abs(hColor3);
		hColor4 = abs(hColor4);
		hColor5 = abs(hColor5);
		hColor6 = abs(hColor6);
		hColor7 = abs(hColor7);
		
		hColor = max(max(max(hColor0, hColor1), max(hColor2, hColor3)), 
					 max(max(hColor4, hColor5), max(hColor6, hColor7)));
	} else {
		for(float i = -1.; i <= 1.; i++) 
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
	
	if(filter == 0)
		gl_FragColor = vec4(vec3(distance(hColor / 4., vColor / 4.)), point.a);
	else if(filter == 1)
		gl_FragColor = vec4(vec3(distance(hColor / 3., vColor / 3.)), point.a);
	else if(filter == 2)
		gl_FragColor = vec4(hColor.rgb / 2., point.a);
	else if(filter == 3)
		gl_FragColor = vec4(abs(hColor.rgb), point.a);
}
