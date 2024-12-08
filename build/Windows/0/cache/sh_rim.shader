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
uniform float rotation;

float d(vec4 c) { return (c.r + c.g + c.b) / 3. * c.a; }

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = texture2D( gm_BaseTexture, v_vTexcoord );
	int emp = 0;
	
	vec2 px = v_vTexcoord * dimension;
	
	gl_FragColor = vec4(0.);
	
	if(d(cc) > 0.) {
		float ang = radians(rotation);
		vec2  sx  = vec2(cos(ang), -sin(ang)) * tx;
		vec4  c;
		
		for(float i = 1.; i <= 1.; i++) {
			vec2 ss = v_vTexcoord + sx * float(i);
			
			c = texture2D( gm_BaseTexture, ss );
			if(d(c) == 0.) emp++;
			else           break;
		}
	}
	
	if(emp >= 1) gl_FragColor = cc;
}

