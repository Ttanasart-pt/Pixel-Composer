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

uniform int   drawLayer;
uniform int   eraser;
uniform vec4  channels;
uniform vec4  pickColor;
uniform float alpha;

uniform sampler2D back;
uniform sampler2D fore;

void main() {
	vec4 bc = texture2D( back, v_vTexcoord );
	vec4 fc = texture2D( fore, v_vTexcoord );
	
	fc   *= channels;
	fc.a *= alpha;
	
	if(eraser == 1) {
		bc -= fc;
		gl_FragColor = bc;
		return;
	}
	
	gl_FragColor = bc;
	
	if(drawLayer == 1) {
		vec4 temp = fc;
		fc = bc;
		bc = temp;
	}
	
	if(drawLayer == 2) {
		if(bc != pickColor) return;
	}
	
	float al = fc.a + bc.a * (1. - fc.a);
	vec4 res = ((fc * fc.a) + (bc * bc.a * (1. - fc.a))) / al;
	res.a = al;
	
	gl_FragColor = res;
}

