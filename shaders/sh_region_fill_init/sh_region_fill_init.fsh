//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    vec4 c   = texture2D( gm_BaseTexture, v_vTexcoord );
	vec3 _c  = c.rgb * c.a;
	float _f = _c.r + _c.g + _c.b;
	
	gl_FragColor = _f == 0.? vec4(0.) : vec4(v_vTexcoord, 0., 1.);
}
