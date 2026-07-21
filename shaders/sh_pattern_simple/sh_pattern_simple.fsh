varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 baseDimension;
uniform vec2 pattDimension;

uniform sampler2D mask;
uniform int useMask;

uniform sampler2D pattern;

uniform vec2 offset;
uniform vec2 scale;

uniform vec4 color1;
uniform vec4 color2;

void main() {
	vec2 px = floor(v_vTexcoord * baseDimension) - offset;
	vec2 patSize = pattDimension * scale;
	vec2 patPos  = mod(px, patSize) + .5;
	
	vec4 patSamp = texture2D(pattern, patPos / patSize);
	gl_FragColor = patSamp.r > .5? color2 : color1;
	
	if(useMask == 1) {
		vec4  m  = texture2D(mask, v_vTexcoord);
		float ma = (m.r + m.g + m.b) / 3. * m.a;
		gl_FragColor.a = ma;
	}
	
}