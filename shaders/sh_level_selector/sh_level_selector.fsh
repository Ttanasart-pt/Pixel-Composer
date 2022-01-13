//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float middle;
uniform float range;

void main() {
	vec4 col  = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	float bright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
	if(bright > middle + range || bright < middle - range)
		gl_FragColor = vec4(0., 0., 0., 1.);
	else
		gl_FragColor = vec4(1., 1., 1., 1.);
	gl_FragColor.a = col.a;
}
