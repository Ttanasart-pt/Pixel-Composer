//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float tol;

bool eq(in vec4 c1, in vec4 c2) {
	return distance(c1, c2) <= tol;
}

void main() {
	vec2 pixel = 1. / dimension;
	
	vec2 tex_pos = v_vTexcoord;
	vec2 pos_A = clamp(tex_pos + vec2(-pixel.x, -pixel.y), 0., 1.);
	vec2 pos_B = clamp(tex_pos + vec2(      0., -pixel.y), 0., 1.);
	vec2 pos_C = clamp(tex_pos + vec2( pixel.x, -pixel.y), 0., 1.);
	
	vec2 pos_D = clamp(tex_pos + vec2(-pixel.x,       0.), 0., 1.);
	vec2 pos_F = clamp(tex_pos + vec2( pixel.x,       0.), 0., 1.);
	
	vec2 pos_G = clamp(tex_pos + vec2(-pixel.x,  pixel.y), 0., 1.);
	vec2 pos_H = clamp(tex_pos + vec2(      0.,  pixel.y), 0., 1.);
	vec2 pos_I = clamp(tex_pos + vec2( pixel.x,  pixel.y), 0., 1.);
	
	
	vec4 A = texture2D( gm_BaseTexture, pos_A);
	vec4 B = texture2D( gm_BaseTexture, pos_B);
	vec4 C = texture2D( gm_BaseTexture, pos_C);
	
	vec4 D = texture2D( gm_BaseTexture, pos_D);
	vec4 E = texture2D( gm_BaseTexture, tex_pos);
	vec4 F = texture2D( gm_BaseTexture, pos_F);
	
	vec4 G = texture2D( gm_BaseTexture, pos_G);
	vec4 H = texture2D( gm_BaseTexture, pos_H);
	vec4 I = texture2D( gm_BaseTexture, pos_I);
	
	vec2 rem = floor(fract(tex_pos * dimension) * 3.);
	float index = rem.y * 3. + rem.x;
	
	gl_FragColor = E;
	
	if(!eq(B, H) && !eq(D, F)) {
		if(index == 0. && eq(D, B))
			gl_FragColor = D;
		else if(index == 1. && ((eq(D, B) && !eq(E, C)) || (eq(B, F) && !eq(E, A))))
			gl_FragColor = B;
		else if(index == 2. && eq(B, F))
			gl_FragColor = F;
		else if(index == 3. && ((eq(D, B) && !eq(E, G)) || (eq(D, H) && !eq(E, A))))
			gl_FragColor = D;
		else if(index == 5. && ((eq(B, F) && !eq(E, I)) || (eq(H, F) && !eq(E, C))))
			gl_FragColor = F;	
		else if(index == 6. && eq(D, H))
			gl_FragColor = D;
		else if(index == 7. && ((eq(D, H) && !eq(E, I)) || (eq(H, F) && !eq(E, G))))
			gl_FragColor = H;
		else if(index == 8. && eq(H, F))
			gl_FragColor = F;
	}
}
