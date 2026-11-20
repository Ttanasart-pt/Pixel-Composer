#pragma use(sampler_simple)
#region -- sampler_simple -- [1794912035.362913]
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

    vec2 getUVA(in vec2 uv, out float alpha) {
        if(useUvMap == 0) {
            alpha = 1.0;
            return uv;
        }

        vec4 samUV = texture2D( uvMap, uv );
        vec2 vuv = vec2(samUV.x, 1. - samUV.y);
        alpha    = samUV.a;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }

    vec2 getSamplePos(vec2 pos, float mapBlend) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, pos).xy;
            map.y    = 1.0 - map.y;
            pos      = mix(pos, map, mapBlend * uvMapMix);
        }

        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return pos;
        
		     if(sampleMode == 3) return clamp(pos, 0., 1.);
		else if(sampleMode == 4) return fract(pos);
        // 5
		else if(sampleMode == 6) { vec2 sp = vec2(fract(pos.x), pos.y); return sp; } 
		else if(sampleMode == 7) { vec2 sp = vec2(fract(pos.x), pos.y); return sp; } 
		else if(sampleMode == 8) return vec2(fract(pos.x), clamp(pos.y, 0., 1.));
		// 9
		else if(sampleMode == 10) { vec2 sp = vec2(pos.x, fract(pos.y)); return sp; } 
		else if(sampleMode == 11) { vec2 sp = vec2(pos.x, fract(pos.y)); return sp; } 
		else if(sampleMode == 12) return vec2(clamp(pos.x, 0., 1.), fract(pos.y));
		
        return pos;
    }
    vec2 getSamplePos(vec2 pos) { return getSamplePos(pos, 0.); }
    
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
uniform int  edge;
uniform int  sides[9];

uniform int  colorMode;
uniform vec2 levelIn, levelOut; float applyLevel(float v) { return mix(levelOut.x, levelOut.y, (v - levelIn.x) / (levelIn.y - levelIn.x)); }

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
			
			bool cnt = edge == 1 || (edge == 0 && sam.a > 0.);
			
			if(sides[0] == 1 && cnt) hColor0 += sam * laplac_r0[jj][ii];
			if(sides[1] == 1 && cnt) hColor1 += sam * laplac_r1[jj][ii];
			if(sides[2] == 1 && cnt) hColor2 += sam * laplac_r2[jj][ii];
			if(sides[3] == 1 && cnt) hColor3 += sam * laplac_r3[jj][ii];
			
			if(sides[5] == 1 && cnt) hColor5 += sam * laplac_r5[jj][ii];
			if(sides[6] == 1 && cnt) hColor6 += sam * laplac_r6[jj][ii];
			if(sides[7] == 1 && cnt) hColor7 += sam * laplac_r7[jj][ii];
			if(sides[8] == 1 && cnt) hColor8 += sam * laplac_r8[jj][ii];
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
		vec4 sam;
		bool cnt;
		
		for(float i = -1.; i <= 1.; i++) 
		for(float j = -1.; j <= 1.; j++) {
			vec2 pxs = v_vTexcoord + vec2(texel.x * i, texel.y * j);
			pxs = clamp(pxs, vec2(0.), vec2(1.));
			
			sam = sampleTexture( gm_BaseTexture, pxs );
			cnt = edge == 1 || (edge == 0 && sam.a > 0.);
			if(!cnt) continue;
			
			int ii = int(1. + i);
			int jj = int(1. + j);
			
			if(filter == 0) {
				hColor += sam * sobel[jj][ii];
				vColor += sam * sobel[ii][jj];
				
			} else if(filter == 1) {
				hColor += sam * prewit[jj][ii];
				vColor += sam * prewit[ii][jj];	
				
			} else if(filter == 2) {
				hColor += sam * laplac[jj][ii];
			}
		}
	}
	
	vec4 res = point;
	
	     if(filter == 0) res = vec4(vec3(distance(hColor / 4., vColor / 4.)), point.a);
	else if(filter == 1) res = vec4(vec3(distance(hColor / 3., vColor / 3.)), point.a);
	else if(filter == 2) res = vec4(hColor.rgb / 2., point.a);
	else if(filter == 3) res = vec4(abs(hColor.rgb), point.a);
	
	res.r = applyLevel(res.r);
	res.g = applyLevel(res.g);
	res.b = applyLevel(res.b);
	
	float gr = bright(res);
	if(colorMode == 1) res.rgb = vec3(gr);
	if(colorMode == 2) res.rgb = vec3(step(.5, gr));
	
	gl_FragColor = res * v_vColour;
}
