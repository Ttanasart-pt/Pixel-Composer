//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float wmin;
uniform float wmax;
uniform float rmin;
uniform float rmax;
uniform float gmin;
uniform float gmax;
uniform float bmin;
uniform float bmax;

void main() {
	vec4 col  = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	col.r = (col.r - rmin) / (rmax - rmin);
	col.g = (col.g - gmin) / (gmax - gmin);
	col.b = (col.b - bmin) / (bmax - bmin);
	
	col.r = (col.r - wmin) / (wmax - wmin);
	col.g = (col.g - wmin) / (wmax - wmin);
	col.b = (col.b - wmin) / (wmax - wmin);
	
    gl_FragColor = col;
}
