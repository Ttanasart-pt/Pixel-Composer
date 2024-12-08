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

uniform vec4  color;
uniform int   fill;
uniform float thickness;
uniform float antialias;
uniform float radius;

void main() {
	float th = thickness == 0.? 0.05 : thickness;
	float aa = antialias == 0.? 0.05 : antialias;
	float rr = radius == 0.? 0.5 : radius; 
	
	float dist = length(v_vTexcoord - .5) / rr - (1. - th - aa);
	float a;
	
	if(fill == 0) {
		dist = abs(dist);
		a = smoothstep(th + aa, th, dist);
		
	} else if(fill == 1) {
		a = smoothstep(aa, 0., dist);
	}
	
	vec4  c = vec4(color.rgb, color.a * a);
	
	gl_FragColor = c;
}

