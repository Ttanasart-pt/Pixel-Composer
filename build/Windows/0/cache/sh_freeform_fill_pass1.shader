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

uniform vec2  dimension;
uniform float itr;

float isInside(vec2 axis) {
	vec2 tx = 1. / dimension;
	vec2 ax = axis * tx;
	
	float overlap = 0.;
	float filling = 0.;
	
	for(float i = 1.; i < itr; i++) {
		vec2 sx = v_vTexcoord + ax * i;
		if(sx.x > 1. || sx.y > 1. || sx.x < 0. || sx.y < 0.) break;
		
		vec4 cc = texture2D( gm_BaseTexture, sx );
		
		if(cc == v_vColour) {
			vec2 px_p = sx - ax + ax.yx;
			vec2 px_n = sx - ax - ax.yx;
			
			vec4 cp = texture2D( gm_BaseTexture, px_p );
			vec4 cn = texture2D( gm_BaseTexture, px_n );
			
			if(filling == 0.) {
				
				if(cp == v_vColour && cn == v_vColour) {
					filling = 2.;
					overlap++;
				} else if(cp == v_vColour || cn == v_vColour) {
					if(cp == v_vColour) {
						filling = 1.;
						overlap++;
					}
				
					if(cn == v_vColour) {
						filling = -1.;
						overlap++;
					}
				} else {
					
					vec4 ccp = texture2D( gm_BaseTexture, px_p + ax );
					vec4 ccn = texture2D( gm_BaseTexture, px_n + ax );
					
					if(ccp == v_vColour && ccn == v_vColour) {
						filling = 2.;
						overlap++;
					}
				}
			}
			
		} else if(filling != 0.) {
			vec2 px_p = sx - ax + ax.yx;
			vec2 px_n = sx - ax - ax.yx;
			
			vec4 cp = texture2D( gm_BaseTexture, px_p );
			vec4 cn = texture2D( gm_BaseTexture, px_n );
			
			if(filling == 1. && cp == v_vColour)
				overlap++;
			
			if(filling == -1. && cn == v_vColour) 
				overlap++;
			
			filling = 0.;
		}
	}
	
	return mod(overlap, 2.);
}

void main() {
	vec4 c  = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = vec4(0.);
	
	if(c == v_vColour) {
		gl_FragColor = vec4(1.);
		return;
	}
	
	float chk = 0.;
	
	chk += isInside(vec2(-1.,  0.));
	chk += isInside(vec2( 1.,  0.));
	chk += isInside(vec2( 0., -1.));
	chk += isInside(vec2( 0.,  1.));
	
	     if(chk == 1.) gl_FragColor = vec4(1., 0., 0., 1.);
	else if(chk == 2.) gl_FragColor = vec4(0., 1., 0., 1.);
	else if(chk == 3.) gl_FragColor = vec4(0., 0., 1., 1.);
	else if(chk == 4.) gl_FragColor = vec4(1.);
	
}

