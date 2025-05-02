varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  process;
uniform int  inverted;

float light(vec4 cc) { return (cc.r + cc.g + cc.b) / 3. * cc.a; } 
float bw(vec4 cc) { return step(.5, light(cc)); }

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = cc;
	
	// if(light(cc) > 0.) return;
	
	// vec4 c0 = texture2D(gm_BaseTexture, v_vTexcoord + direction * tx);
	// vec4 c1 = texture2D(gm_BaseTexture, v_vTexcoord - direction * tx);
	// vec4 c2 = texture2D(gm_BaseTexture, v_vTexcoord - (direction + direction.yx) * tx);
	// vec4 c3 = texture2D(gm_BaseTexture, v_vTexcoord - (direction - direction.yx) * tx);
	
	// if(light(c0) > 0. && light(c1) == 0. && light(c2) == 0. && light(c3) == 0.) 
	// 	gl_FragColor = vec4(1., 1., 1., 1.);
	
	//// Zhang-Suen thinning algorithm
	
	float p1 = bw(cc);
	
	float p9 = bw(texture2D(gm_BaseTexture, v_vTexcoord + vec2(-tx.x, -tx.y)));
	float p2 = bw(texture2D(gm_BaseTexture, v_vTexcoord + vec2(   0., -tx.y)));
	float p3 = bw(texture2D(gm_BaseTexture, v_vTexcoord + vec2( tx.x, -tx.y)));
	
	float p8 = bw(texture2D(gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.)));
	float p4 = bw(texture2D(gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.)));
	
	float p7 = bw(texture2D(gm_BaseTexture, v_vTexcoord + vec2(-tx.x, tx.y)));
	float p6 = bw(texture2D(gm_BaseTexture, v_vTexcoord + vec2(   0., tx.y)));
	float p5 = bw(texture2D(gm_BaseTexture, v_vTexcoord + vec2( tx.x, tx.y)));
	
	float a = 0.;
	if(p2 == 0. && p3 == 1.) a += 1.;
	if(p3 == 0. && p4 == 1.) a += 1.;
	if(p4 == 0. && p5 == 1.) a += 1.;
	if(p5 == 0. && p6 == 1.) a += 1.;
	if(p6 == 0. && p7 == 1.) a += 1.;
	if(p7 == 0. && p8 == 1.) a += 1.;
	if(p8 == 0. && p9 == 1.) a += 1.;
	if(p9 == 0. && p2 == 1.) a += 1.;
	
	float b = p9 + p2 + p3 + p8 + p4 + p7 + p6 + p5;
	float pass = p1;
	
	if(inverted == 0) {
		if(process == 0) {
			if((p1 == 1.)                         && 
			   (2. <= b && b <= 6.)               && 
			   (a == 1.)                          && 
			   (p2 == 0. || p4 == 0. || p6 == 0.) && 
			   (p4 == 0. || p6 == 0. || p8 == 0.) ) 
				  pass = 0.;
				  
		} else if(process == 1) {
			if((p1 == 1.)                         && 
			   (2. <= b && b <= 6.)               && 
			   (a == 1.)                          && 
			   (p2 == 0. || p4 == 0. || p8 == 0.) && 
			   (p2 == 0. || p6 == 0. || p8 == 0.) ) 
				  pass = 0.;
		}
		
	} else {
		if(process == 0) {
			if((p1 == 0.)                         && 
			   (2. <= b && b <= 6.)               && 
			   (a == 1.)                          && 
			   (p2 == 1. || p4 == 1. || p6 == 1.) && 
			   (p4 == 1. || p6 == 1. || p8 == 1.) ) 
				  pass = 1.;
				  
		} else if(process == 1) {
			if((p1 == 0.)                         && 
			   (2. <= b && b <= 6.)               && 
			   (a == 1.)                          && 
			   (p2 == 1. || p4 == 1. || p8 == 1.) && 
			   (p2 == 1. || p6 == 1. || p8 == 1.) ) 
				  pass = 1.;
		}
		
	}
	
	gl_FragColor = vec4(vec3(pass), 1.);
}