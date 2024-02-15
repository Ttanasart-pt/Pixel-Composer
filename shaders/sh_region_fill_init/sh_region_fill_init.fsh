varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 targetColor;

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(targetColor.a == 0.)
		gl_FragColor = c.a == 0.? vec4(1., 0., 0., 1.) : vec4(0.);
	else 
		gl_FragColor = targetColor == c? vec4(1., 0., 0., 1.) : vec4(0.);
}
