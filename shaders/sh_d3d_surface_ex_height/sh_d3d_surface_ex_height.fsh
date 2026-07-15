varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 level;

void main() {
	vec4  res = texture2D(gm_BaseTexture, v_vTexcoord);
	
	float bri = (res.r + res.g + res.b) / 3. * res.a;
	      bri = (bri - level.x) / (level.y - level.x);
	
	gl_FragColor = vec4(bri, bri, bri, 1.);
}