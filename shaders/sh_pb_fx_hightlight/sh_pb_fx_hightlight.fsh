varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform vec4  highlight_width;
uniform vec4  highlight_l;
uniform vec4  highlight_r;
uniform vec4  highlight_t;
uniform vec4  highlight_b;

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	
	if(cc.a > 0.) {
		int   high = -1;
		float dist = 9999.;
		
		for(float i = 1.; i <= highlight_width[2]; i++) {
			vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-1., 0.) * i * tx);
			if(samp.a == 0.) { if(i < dist) { dist = i; high = 0; } break; }
		}
		
		for(float i = 1.; i <= highlight_width[0]; i++) {
			vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord + vec2( 1., 0.) * i * tx);
			if(samp.a == 0.) { if(i < dist) { dist = i; high = 1; } break; }
		}
		
		for(float i = 1.; i <= highlight_width[1]; i++) {
			vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0., -1.) * i * tx);
			if(samp.a == 0.) { if(i < dist) { dist = i; high = 2; } break; }
		}
		
		for(float i = 1.; i <= highlight_width[3]; i++) {
			vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.,  1.) * i * tx);
			if(samp.a == 0.) { if(i < dist) { dist = i; high = 3; } break; }
		}
		
		     if(high == 0) cc = highlight_l;
		else if(high == 1) cc = highlight_r;
		else if(high == 2) cc = highlight_t;
		else if(high == 3) cc = highlight_b;
	}
	
	gl_FragColor = cc;
}