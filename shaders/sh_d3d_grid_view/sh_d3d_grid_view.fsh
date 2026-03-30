#ifdef _YY_HLSL11_
	#extension GL_OES_standard_derivatives : enable
#endif

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying float v_distanceToCamera;
varying vec3 v_worldPosition;

uniform float scale;
uniform vec2  shift;

uniform float axisBlend;

void main() {
	vec2 cen = v_vTexcoord - .5;
	vec2 pos = cen + shift;
	
    vec2  coord = pos * scale; // use the scale variable to set the distance between the lines
    vec2  dev   = fwidth(coord);
    vec2  grid  = abs(fract(coord - 0.5) - 0.5) / dev;
    float line  = min(grid.x, grid.y);
    float miny  = min(dev.y, 1.);
    float minx  = min(dev.x, 1.);
    
    float linea = 1. - min(line, 1.);
    float alpha = 1. - length(cen);
    vec4 color  = vec4(.6, .6, .6, linea * alpha);
	
    // y axis
    if(pos.x > -1. * minx / scale && pos.x < 1. * minx / scale)
    	color = vec4(0., 1., 0., linea * axisBlend);
        
    // x axis
    if(pos.y > -1. * miny / scale && pos.y < 1. * miny / scale)
    	color = vec4(1., 0., 0., linea * axisBlend);
	
    gl_FragColor = color;
}
