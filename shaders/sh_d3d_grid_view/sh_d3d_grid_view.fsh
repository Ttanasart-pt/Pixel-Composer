#define MACOS 1

#ifndef MACOS
	#extension GL_OES_standard_derivatives : enable
#endif

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying float v_distanceToCamera;
varying vec3 v_worldPosition;

uniform float scale;
uniform vec2  shift;

uniform float axisBlend;

vec4 grid(vec2 pos, float scale) {
	#ifdef MACOS
		vec4 color = vec4(0.);
	#else
	    vec2 coord = pos * scale; // use the scale variable to set the distance between the lines
	    vec2 derivative = fwidth(coord);
	    vec2 grid  = abs(fract(coord - 0.5) - 0.5) / derivative;
	    float line = min(grid.x, grid.y);
	    float minimumy = min(derivative.y, 1.);
	    float minimumx = min(derivative.x, 1.);
	    vec4 color = vec4(.3, .3, .3, 1. - min(line, 1.));
	    // y axis
	    if(pos.x > -1. * minimumx / scale && pos.x < 1. * minimumx / scale)
	        color.y = 0.3 + axisBlend * 0.7;
	    // x axis
	    if(pos.y > -1. * minimumy / scale && pos.y < 1. * minimumy / scale)
	        color.x = 0.3 + axisBlend * 0.7;
	#endif
	
	
	
    return color;
}

void main() {
    gl_FragColor = grid( v_vTexcoord - 0.5 + shift, scale );
	gl_FragColor.a *= 1. - length(v_vTexcoord - 0.5) * 2.;
}
