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

uniform sampler2D fore;
uniform float opacity;
uniform int preserveAlpha;

void main() {
	vec4 _col0 = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 _col1 = texture2D( fore, v_vTexcoord );
	
	vec4 res = _col0 + _col1 * opacity;
	
	////////// Alpha
	float bright = dot(_col1.rgb, vec3(0.2126, 0.7152, 0.0722));
	float aa = _col0.a + bright * opacity;
	res.a = aa;
	if(preserveAlpha == 1) res.a = _col0.a;
	
    gl_FragColor = res;
}

