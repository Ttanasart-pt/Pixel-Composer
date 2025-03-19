varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float size;
uniform float tolerance;

uniform int useMask;
uniform sampler2D mask;

void main() {
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	float bright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
	if(bright > tolerance)
		gl_FragColor = col;
	else 
		gl_FragColor = vec4(vec3(0.), 1.);
		
	if(useMask == 1) 
		gl_FragColor = col * texture2D( mask, v_vTexcoord );
}
