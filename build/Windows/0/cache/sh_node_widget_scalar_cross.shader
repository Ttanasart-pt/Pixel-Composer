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
uniform float index;
uniform int   type;

float line_segment(in vec2 a, in vec2 b) {
	vec2 p = v_vTexcoord;
	
	vec2 ba = b - a;
	vec2 pa = p - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
	return length(pa - h * ba);
}

void main() {
	float dist;
	float a = 0.3 - index * 0.1;
	float b = 1. - a;
	
	dist = min(line_segment(vec2(0.5, a), vec2(0.5, b)), 
			   line_segment(vec2(a, 0.5), vec2(b, 0.5))
		   ) * 3.;
	dist = 1. - dist - 0.5;
	
	vec4  c = vec4(0.);
	
	if(type == 0) { 
		a = smoothstep(.0, .1, dist);
		c = mix(c, vec4(0., 0., 0., 1.), a);      
		
		a = smoothstep(.15, .2, dist);
		c = mix(c, vec4(1., 1., 1., 1.), a);
		
		a = smoothstep(.3, .4, dist);
		c = mix(c, color, a);
		
	} else if(type == 1) { 
		a = smoothstep(.3, .4, dist);
		c = mix(c, color, a);
	}
	
	gl_FragColor = c;
}

