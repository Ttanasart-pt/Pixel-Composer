varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 targetColor;
uniform float threshold;

bool sameColor(in vec4 c0, in vec4 c1) { return distance(c0.rgb * c0.a, c1.rgb * c1.a) <= threshold; }

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(targetColor.a == 0.) gl_FragColor = c.a == 0.? vec4(1., 0., 0., 1.) : vec4(0.);
	else                    gl_FragColor = sameColor(targetColor, c)? vec4(1., 0., 0., 1.) : vec4(0.);
}
