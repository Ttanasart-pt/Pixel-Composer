varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  p0, p1;
uniform vec4  color;

uniform int   dithering;
uniform float ditherSize;
uniform float dither[64];

void main() {
    vec4 c0 = texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor = c0;
    
    if(c0.a == 0.) return;
    
    vec2  px = floor(v_vTexcoord * dimension);
    vec2  dr = p1 - p0;
    float ls = dot(dr, dr);
	
    vec2  dx  = px - p0;
    float rat = clamp(dot(dx, dr) / ls, 0.0, 1.0);
	
	if(dithering == 1) {
		float col = px.x - floor(px.x / ditherSize) * ditherSize;
		float row = px.y - floor(px.y / ditherSize) * ditherSize;
		float ditherVal = dither[int(row * ditherSize + col)] / (ditherSize * ditherSize);

		if(rat <= ditherVal) 
			 rat = 0.;
		else rat = 1.;	
	}
	
    vec4 res = mix(c0, color, rat);
    gl_FragColor = res;
}