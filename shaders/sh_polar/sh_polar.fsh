//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define pi2 1.57079

void main() {
	vec2  center	= v_vTexcoord - vec2(0.5, 0.5);
	float radius	= distance(v_vTexcoord, vec2(0.5, 0.5)) / (sqrt(2.) * .5);
	float angle		= (atan(center.y, center.x) / pi2 + 1.) / 2.;
	
	vec2 polar = vec2(radius, angle);
    gl_FragColor = v_vColour * texture2D( gm_BaseTexture, polar );
}
