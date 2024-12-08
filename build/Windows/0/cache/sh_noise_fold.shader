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
// Based on FabriceNeyret2 - plop 2 shader

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

uniform int   iteration;
uniform float stretch;
uniform float amplitude;

uniform int   mode;

void main() {
	vec2  ntx = v_vTexcoord * vec2(1., dimension.y / dimension.x);
	float ang = radians(rotation);
    vec2  pos = (ntx - position / dimension) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * scale;
	vec4  col = vec4(0., 0., 0., 1.);
	
    for (int i = 0; i < iteration; i++) {
    	pos += cos( pos.yx * 3. + vec2(0.0, stretch)) / 3.;
        pos += sin( pos.yx      + vec2(stretch, 0.0)) / 2.;
        pos *= amplitude;
    }
    
	if(mode == 0) col += length(mod(pos, 2.) - 1.);
	else          col.xy += abs(mod(pos, 2.) - 1.);
	
    gl_FragColor = col;
}

