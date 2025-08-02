varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D baseSurface;
uniform sampler2D lightSurface;
uniform vec4  ambient;
uniform int   keepAlpha;

void main() {
	vec4  baseColor = texture2D( baseSurface,  v_vTexcoord );
	vec4  lighColor = texture2D( lightSurface, v_vTexcoord );
	
	vec4 res = baseColor * ambient + lighColor;
	if(keepAlpha == 1) res.a = baseColor.a;
	
	gl_FragColor = res;
}
