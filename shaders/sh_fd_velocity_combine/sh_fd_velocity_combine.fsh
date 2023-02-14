//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D v1;
uniform sampler2D v2;

void main() {
	vec4 _v1 = texture2D( v1, v_vTexcoord );
	vec4 _v2 = texture2D( v2, v_vTexcoord );
	vec4 _v3 = vec4(0.);
	float hf = 128. / 255.;
	
	_v3.x = hf + (_v1.x - hf) + (_v2.x - hf);
	_v3.y = hf + (_v1.y - hf) + (_v2.y - hf);
	_v3.z = _v1.z + _v2.z;
	_v3.a = _v1.a + _v2.a;
	
    gl_FragColor = _v3;
}
