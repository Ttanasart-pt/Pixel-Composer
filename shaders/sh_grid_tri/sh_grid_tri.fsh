/*
	Triangular Grid
	03/2016
	seb chevrel
*/

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform vec2  scale;
uniform float angle;
uniform float thick;

#define PI 3.1415926535897

// triangle rotation matrices
vec2 v60 = vec2(cos(PI / 3.0), sin(PI / 3.0));
vec2 vm60 = vec2(cos(-PI / 3.0), sin(-PI / 3.0));
mat2 rot60 = mat2(v60.x, -v60.y, v60.y, v60.x);
mat2 rotm60 = mat2(vm60.x, -vm60.y, vm60.y, vm60.x);    

float triangleGrid(vec2 p, float stepSize, float vertexSize, float lineSize)  {
    // equilateral triangle grid
    vec2 fullStep = vec2( stepSize, stepSize * v60.y);
    vec2 halfStep = fullStep / 2.0;
    vec2 grid = floor(p / fullStep);
    vec2 offset = vec2( (mod(grid.y, 2.0) == 1.0) ? halfStep.x : 0., 0.);
   	// tiling
    vec2 uv = mod(p + offset, fullStep) - halfStep;
    float d2 = dot(uv, uv);
    return vertexSize / d2 + // vertices 
    	max( abs(lineSize / (uv * rotm60).y), // lines -60deg
        	 max ( abs(lineSize / (uv * rot60).y), // lines 60deg
        	  	   abs(lineSize / uv.y) )); // h lines
}

void main() {
	float time = 1.;
	vec2 pos = (v_vTexcoord - position) / scale, _pos;
	float ratio = dimension.x / dimension.y;
	
	_pos.x = pos.x * ratio * cos(angle) - pos.y * sin(angle);
	_pos.y = pos.x * ratio * sin(angle) + pos.y * cos(angle);
    vec3 color = triangleGrid(_pos, 0.1, 0., thick / 100.) * vec3(0.8, 0.8, 0.85);
	color = vec3((color[0] + color[1] + color[2]) / 3.);
    color = step(0.75, 1. - color);
	
	gl_FragColor = vec4(color ,1.0);
}
