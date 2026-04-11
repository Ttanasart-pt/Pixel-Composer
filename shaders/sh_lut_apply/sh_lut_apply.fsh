varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D lutSurface;
uniform float     lutSize; // 33

uniform float     strength;

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	
	float pxr = floor(base.r * lutSize);
	float pxg = floor(base.g * lutSize) * lutSize;
	float pxb = floor(base.b * lutSize);
	
	float px  = pxr + pxg;
	float py  = pxb;
	
	vec2 lutPos  = vec2( (px + .5) / (lutSize * lutSize), (py + .5) / lutSize );
	
	vec4 lutC = texture2D(lutSurface, lutPos);
	vec4 res  = mix(base, lutC, strength);
	
	res.a = base.a;
	gl_FragColor = res;
}