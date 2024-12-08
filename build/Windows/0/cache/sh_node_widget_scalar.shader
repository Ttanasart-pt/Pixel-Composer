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

void main() {
	float dist  = 1. - length(v_vTexcoord - .5) * 2.;
	      dist -= mix(.2, .0, index);
		  
	float a;
	vec4  c = vec4(0.);
	
	if(type == 0) { 
		a = smoothstep(.0, .1, dist);
		c = mix(c, vec4(0., 0., 0., 1.), a);      
		
		a = smoothstep(.15, .3, dist);
		c = mix(c, vec4(1., 1., 1., 1.), a);
		
		a = smoothstep(.4, .5, dist);
		c = mix(c, color, a);
		
	} else if(type == 1) { 
		a = smoothstep(.3, .4, dist);
		c = mix(c, color, a);
		
	} else if(type == 2) { 
		a = smoothstep(.0, .15, dist);
		c = mix(c, color, a);      
		
		a = smoothstep(.25, .35, dist);
		c = mix(c, vec4(1., 1., 1., 1.), a);
	} 
	
	gl_FragColor = c;
}

