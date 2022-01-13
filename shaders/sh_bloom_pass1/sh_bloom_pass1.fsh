//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float size;
uniform float tolerance;

void main() {
	vec4 col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	float bright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
	if(bright > tolerance)
		gl_FragColor = col;
	else 
		gl_FragColor = vec4(vec3(0.), 1.);
}
