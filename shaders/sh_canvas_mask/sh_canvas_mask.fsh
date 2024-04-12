varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D drawSurface;
uniform sampler2D maskSurface;

void main() {
	vec4 drw = texture2D( drawSurface, v_vTexcoord );
	vec4 msk = texture2D( maskSurface, v_vTexcoord );
	
    gl_FragColor = msk.a > 0.5? drw : texture2D( gm_BaseTexture, v_vTexcoord );
}
