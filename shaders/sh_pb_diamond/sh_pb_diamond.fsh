varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  cornerType;

void main() {
	vec2 px = floor(v_vTexcoord * dimension);
	gl_FragColor = vec4(0.);
	
	float _h = ceil(dimension.y / 2.) - 1.;
	float _w = ceil(dimension.x / 2.) - 1.;
	
	if(px.x > _w) px.x = dimension.x - px.x - 1.;
	if(px.y > _h) px.y = dimension.y - px.y - 1.;
	
	if(cornerType == 0) {
		if(px.x <= _w && px.y <= _h && px.x / _w + px.y / _h >= 1.)
			gl_FragColor = vec4(1.);
			
	} else if(cornerType == 1) {
		if(px.x <= _w && px.y <= _h && px.x + px.y >= min(_w, _h))
			gl_FragColor = vec4(1.);
			
	}
}