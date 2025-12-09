#pragma use(sampler_simple)

#region -- sampler_simple -- [1765194569.6586206]
    uniform int  sampleMode;
    
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(vec2 tx) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, tx).xy;
            map.y    = 1.0 - map.y;
            tx       = mix(tx, map, uvMapMix);
        }
        return tx;
    }

    vec4 sampleTexture( sampler2D texture, vec2 pos, float mapBlend) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, pos).xy;
            map.y    = 1.0 - map.y;
            pos      = mix(pos, map, mapBlend * uvMapMix);
        }

        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
			 if(sampleMode <= 1) return vec4(0.);
		else if(sampleMode == 2) return vec4(0.,0.,0., 1.);
		else if(sampleMode == 3) return texture2D(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 4) return texture2D(texture, fract(pos));
        // 5
		else if(sampleMode == 6) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.) : texture2D(texture, sp); } 
		else if(sampleMode == 7) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.,0.,0.,1.) : texture2D(texture, sp); } 
		else if(sampleMode == 8) return texture2D(texture, vec2(fract(pos.x), clamp(pos.y, 0., 1.)));
		// 9
		else if(sampleMode == 10) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.) : texture2D(texture, sp); } 
		else if(sampleMode == 11) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.,0.,0.,1.) : texture2D(texture, sp); } 
		else if(sampleMode == 12) return texture2D(texture, vec2(clamp(pos.x, 0., 1.), fract(pos.y)));
		
        return vec4(0.);
    }
    vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler_simple --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  filter;
uniform int  sides[9];

#region matrices
	const mat3 sobel     = mat3( -1., -2., -1., 
							      0.,  0.,  0., 
							      1.,  2.,  1.);
		
	const mat3 prewit    = mat3( -1., -1., -1., 
							      0.,  0.,  0., 
							      1.,  1.,  1.);
	
	const mat3 laplac    = mat3(  1.,  1.,  1.,
							      1., -8.,  1., 
							      1.,  1.,  1.);
	
	const mat3 laplac_r0 = mat3(  1.,  0.,  0.,
						     	  0., -1.,  0., 
						     	  0.,  0.,  0.);
	
	const mat3 laplac_r1 = mat3(  0.,  1.,  0.,
						     	  0., -1.,  0., 
						     	  0.,  0.,  0.);
	
	const mat3 laplac_r2 = mat3(  0.,  0.,  1.,
						     	  0., -1.,  0., 
						     	  0.,  0.,  0.);
	
	const mat3 laplac_r3 = mat3(  0.,  0.,  0.,
						     	  1., -1.,  0., 
						     	  0.,  0.,  0.);
	
	const mat3 laplac_r4 = mat3(  0.,  0.,  0.,
						     	  0., -1.,  0., 
						     	  0.,  0.,  0.);
	
	const mat3 laplac_r5 = mat3(  0.,  0.,  0.,
						     	  0., -1.,  1., 
						     	  0.,  0.,  0.);
	
	const mat3 laplac_r6 = mat3(  0.,  0.,  0.,
						     	  0., -1.,  0., 
						     	  1.,  0.,  0.);
	
	const mat3 laplac_r7 = mat3(  0.,  0.,  0.,
						     	  0., -1.,  0., 
						     	  0.,  1.,  0.);
						     	  
	const mat3 laplac_r8 = mat3(  0.,  0.,  0.,
						     	  0., -1.,  0., 
						     	  0.,  0.,  1.);
#endregion

#define TAU 6.283185307179586

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a;
}

void main() {
	vec2 texel = vec2(1.) / dimension;
	vec4 point = sampleTexture( gm_BaseTexture, v_vTexcoord );
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
		vec4 hColor8 = vec4(0.);
		vec2 pxs;
		
		for(float i = -1.; i <= 1.; i++) 
		for(float j = -1.; j <= 1.; j++) {
			pxs = v_vTexcoord + vec2(texel.x * i, texel.y * j);
			pxs = clamp(pxs, vec2(0.), vec2(1.));
			
			int  ii  = int(1. + i);
			int  jj  = int(1. + j);
			vec4 sam = sampleTexture( gm_BaseTexture, pxs );
			
			if(sides[0] == 1) hColor0 += sam * laplac_r0[jj][ii];
			if(sides[1] == 1) hColor1 += sam * laplac_r1[jj][ii];
			if(sides[2] == 1) hColor2 += sam * laplac_r2[jj][ii];
			if(sides[3] == 1) hColor3 += sam * laplac_r3[jj][ii];
			
			if(sides[5] == 1) hColor5 += sam * laplac_r5[jj][ii];
			if(sides[6] == 1) hColor6 += sam * laplac_r6[jj][ii];
			if(sides[7] == 1) hColor7 += sam * laplac_r7[jj][ii];
			if(sides[8] == 1) hColor8 += sam * laplac_r8[jj][ii];
		}
		
		hColor = max(hColor, abs(hColor0));
		hColor = max(hColor, abs(hColor1));
		hColor = max(hColor, abs(hColor2));
		hColor = max(hColor, abs(hColor3));
		
		hColor = max(hColor, abs(hColor5));
		hColor = max(hColor, abs(hColor6));
		hColor = max(hColor, abs(hColor7));
		hColor = max(hColor, abs(hColor8));
		
	} else {
		for(float i = -1.; i <= 1.; i++) 
		for(float j = -1.; j <= 1.; j++) {
			vec2 pxs = v_vTexcoord + vec2(texel.x * i, texel.y * j);
			pxs = clamp(pxs, vec2(0.), vec2(1.));
			
			int ii = int(1. + i);
			int jj = int(1. + j);
			
			if(filter == 0) {
				hColor += sampleTexture( gm_BaseTexture, pxs ) * sobel[jj][ii];
				vColor += sampleTexture( gm_BaseTexture, pxs ) * sobel[ii][jj];
				
			} else if(filter == 1) {
				hColor += sampleTexture( gm_BaseTexture, pxs ) * prewit[jj][ii];
				vColor += sampleTexture( gm_BaseTexture, pxs ) * prewit[ii][jj];	
				
			} else if(filter == 2) {
				hColor += sampleTexture( gm_BaseTexture, pxs ) * laplac[jj][ii];
			}
		}
	}
	
	     if(filter == 0) gl_FragColor = vec4(vec3(distance(hColor / 4., vColor / 4.)), point.a);
	else if(filter == 1) gl_FragColor = vec4(vec3(distance(hColor / 3., vColor / 3.)), point.a);
	else if(filter == 2) gl_FragColor = vec4(hColor.rgb / 2., point.a);
	else if(filter == 3) gl_FragColor = vec4(abs(hColor.rgb), point.a);
}
