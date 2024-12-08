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
#define PI  3.14159265359

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float side;
uniform vec4  color;
uniform float angle;

float line_segment(in float ang) {
	vec2 a = vec2(.5);
	vec2 b = vec2(.5) + vec2(cos(ang), -sin(ang)) * 0.3;
	vec2 p = v_vTexcoord;
	
	vec2 ba = b - a;
	vec2 pa = p - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
	return length(pa - h * ba);
}

void main() {
	float dist   = length(v_vTexcoord - .5) - 0.3;
	float alp    = 0.;
	bool  inside = dist < 0.;
	
	dist = abs(dist);
	alp = max(alp, smoothstep(2. / side, 0.8 / side, dist));
	alp = max(alp, smoothstep(2. / side, 0.8 / side, line_segment(angle)));
	
	gl_FragColor = vec4(color.rgb, alp);
}

