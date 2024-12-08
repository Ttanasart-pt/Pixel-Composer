//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define SPAN 8.

uniform vec2 dimension;

void main() {
	vec2  tx = 1. / dimension;
	vec4  cc = texture2D( gm_BaseTexture, v_vTexcoord );
	float hh = cc.r;
	
	if(hh == 0.) {
		gl_FragColor = vec4(vec3(0.), 1.);
		return;
	}
	
	vec2 px, mn = cc.yz;
	vec4 ss;
	
	for(float i = 1.; i < SPAN; i++) {
		px = v_vTexcoord + vec2(i * tx.x, 0.);
		ss = texture2D( gm_BaseTexture, px );
		
		if(ss.r == 0.) break;
		
		if(ss.r > hh) {
			hh = ss.r; 
			mn = ss.yz;
		} else if(ss.r == hh) {
			if(distance(v_vTexcoord, ss.yz) < distance(v_vTexcoord, mn))
				mn = ss.yz; 
		}
	}
	
	for(float i = 1.; i < SPAN; i++) {
		px = v_vTexcoord - vec2(i * tx.x, 0.);
		ss = texture2D( gm_BaseTexture, px );
		
		if(ss.r == 0.) break;
		
		if(ss.r > hh) {
			hh = ss.r; 
			mn = ss.yz;
		} else if(ss.r == hh) {
			if(distance(v_vTexcoord, ss.yz) < distance(v_vTexcoord, mn))
				mn = ss.yz; 
		}
	}
	
	for(float i = 1.; i < SPAN; i++) {
		px = v_vTexcoord + vec2(0., i * tx.y);
		ss = texture2D( gm_BaseTexture, px );
		
		if(ss.r == 0.) break;
		
		if(ss.r > hh) {
			hh = ss.r; 
			mn = ss.yz;
		} else if(ss.r == hh) {
			if(distance(v_vTexcoord, ss.yz) < distance(v_vTexcoord, mn))
				mn = ss.yz; 
		}
	}
	
	for(float i = 1.; i < SPAN; i++) {
		px = v_vTexcoord - vec2(0., i * tx.y);
		ss = texture2D( gm_BaseTexture, px );
		
		if(ss.r == 0.) break;
		
		if(ss.r > hh) {
			hh = ss.r; 
			mn = ss.yz;
		} else if(ss.r == hh) {
			if(distance(v_vTexcoord, ss.yz) < distance(v_vTexcoord, mn))
				mn = ss.yz; 
		}
	}
	
	gl_FragColor = vec4(hh, mn, 1.);
}

