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

void main() {
    vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	float u = 0.;
	float v = col.b;
	
	if(col.a < 0.5) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	float pos = 0.;
	vec2 scPos = v_vTexcoord;
	for( float i = 0.; i < dimension.x; i++ ) {
		vec4 sm = texture2D( gm_BaseTexture, scPos );
		if(sm.a < 0.5) break;
		
		scPos.x -= sm.y;
		scPos.y += sm.x;
		pos++;
	}
	
	float tot = 0.;
	vec2 scTot = v_vTexcoord;
	for( float i = 0.; i < dimension.x; i++ ) {
		vec4 sm = texture2D( gm_BaseTexture, scTot );
		if(sm.a < 0.5) break;
		
		scTot.x += sm.y;
		scTot.y -= sm.x;
		tot++;
	}
	
	u = pos / (pos + tot);
	gl_FragColor = vec4(u, v, 0., col.a);
}

