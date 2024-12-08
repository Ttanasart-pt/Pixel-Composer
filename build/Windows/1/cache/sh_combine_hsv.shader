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

uniform sampler2D samH;
uniform sampler2D samS;
uniform sampler2D samV;
uniform sampler2D samA;

uniform int useH;
uniform int useS;
uniform int useV;
uniform int useA;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float sample(vec4 col, int ch) { return (col[0] + col[1] + col[2]) / 3. * col[3]; }

void main() {
	float h = (useH == 1)? sample(texture2D( samH, v_vTexcoord ), 0) : 0.;
	float s = (useS == 1)? sample(texture2D( samS, v_vTexcoord ), 1) : 0.;
	float v = (useV == 1)? sample(texture2D( samV, v_vTexcoord ), 2) : 0.;
	float a = (useA == 1)? sample(texture2D( samA, v_vTexcoord ), 3) : 1.;
	
	gl_FragColor = vec4(hsv2rgb(vec3(h, s, v)), a);
}

