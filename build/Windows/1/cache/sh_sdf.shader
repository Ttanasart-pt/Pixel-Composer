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
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float stepSize;
uniform int side;

void main() {
	float c = texture2D( gm_BaseTexture, v_vTexcoord ).z;
	if((side == 0 && c == 0.) || (side == 1 && c == 1.)) {
		gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
		return;
	}
	
	vec2 txStep = stepSize / dimension;
	vec2 loc[9];
	
	loc[0] = v_vTexcoord + vec2(-txStep.x, -txStep.y);
	loc[1] = v_vTexcoord + vec2(       0., -txStep.y);
	loc[2] = v_vTexcoord + vec2(+txStep.x, -txStep.y);
	
	loc[3] = v_vTexcoord + vec2(-txStep.x, 0.);
	loc[4] = v_vTexcoord + vec2(       0., 0.);
	loc[5] = v_vTexcoord + vec2(+txStep.x, 0.);
	
	loc[6] = v_vTexcoord + vec2(-txStep.x, +txStep.y);
	loc[7] = v_vTexcoord + vec2(       0., +txStep.y);
	loc[8] = v_vTexcoord + vec2(+txStep.x, +txStep.y);
	
	vec2 closetPoint = vec2(0., 0.);
	float closetDistance = 9999.;
	
	for( int i = 0 ; i < 9; i++ ) {
		if( loc[i].x < 0. || loc[i].y < 0. || loc[i].x > 1. || loc[i].y > 1. ) continue;
		
		vec4 sam = texture2D( gm_BaseTexture, loc[i] );
		if(sam.z != c) {
			float dist = distance(v_vTexcoord, loc[i]);
			if(dist < closetDistance) {
				closetDistance = dist;
				closetPoint = loc[i];
			}
			continue;
		}
		
		if(sam.xy == vec2(0.)) continue;
		float dist = distance(v_vTexcoord, sam.xy);
		if(dist < closetDistance) {
			closetDistance = dist;
			closetPoint = sam.xy;
		}
	}
	
	gl_FragColor = vec4(closetPoint, c, 1.);
}

