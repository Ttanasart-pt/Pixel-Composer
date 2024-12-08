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

uniform vec2  dimension;
uniform vec4  c0, c1;
uniform float mouseProg;
uniform float prog;

void main() {
	vec2  px   = v_vTexcoord * dimension;
	vec2  norm = abs(v_vTexcoord - vec2(0.5));
    float bar  = 1. - norm.y * 2.;
	
	float rr = dimension.y / 2.;
	if(px.x < rr)						bar = 1. - distance(px, vec2(rr, rr)) / rr;
	else if(px.x > dimension.x - rr)	bar = 1. - distance(px, vec2(dimension.x - rr, rr)) / rr;
	bar = clamp(bar, 0., 1.);
	
	float dif = abs(v_vTexcoord.x - prog);
	float d0  = clamp(smoothstep(0.9 + mouseProg * 0.05, 1.00, 1. - dif) * 1., 0., 1.);
	float d1  = clamp(1. - smoothstep(0.85 + mouseProg * 0.05, 1.00, 1. - dif) * 2., 0., 0.75);
	float rad = 0.8 - d0 * (mouseProg * 0.25 + 0.4);
	
	bar = smoothstep(rad, 1.0, bar) * 25.;
	
    gl_FragColor = vec4(mix(c0.rgb, c1.rgb, d1), bar);
}

