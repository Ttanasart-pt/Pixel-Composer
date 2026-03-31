#ifdef _YY_HLSL11_
	#extension GL_OES_standard_derivatives : enable
#endif

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying float v_distanceToCamera;
varying vec3 v_worldPosition;

uniform float scale;
uniform float fade;
uniform vec2  shift;

uniform float axisBlend;

void main() {
	vec2 cen = v_vTexcoord - .5;
	vec2 pos = cen + shift;
	
    vec2  coord = pos * scale; // use the scale variable to set the distance between the lines
    vec2  dev   = fwidth(coord);
    vec2  grid  = abs(fract(coord - .5) - .5) / dev;
    float line  = min(grid.x, grid.y);
    float miny  = min(dev.y, 1.);
    float minx  = min(dev.x, 1.);
    
    float linea = 1.1 - min(line, 1.1);
    float alpha = length(cen) * 2.;
          alpha = 1. - alpha * alpha;
	
    float g = .8;
    float a = linea * fade;
    
         if(mod(abs(pos.x) * scale, 4.) < minx) { a += .4; }
    else if(mod(abs(pos.y) * scale, 4.) < miny) { a += .4; }
    
    vec4 color  = vec4(g, g, g, a * alpha);
	
	linea = 1.2 - min(line, 1.2);
    if(abs(pos.x) * scale < minx) color = vec4(0., 1., 0., linea * axisBlend * min(1., alpha * 2.));
    if(abs(pos.y) * scale < miny) color = vec4(1., 0., 0., linea * axisBlend * min(1., alpha * 2.));
	
    gl_FragColor = color;
}
