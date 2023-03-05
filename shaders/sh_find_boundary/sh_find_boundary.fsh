//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  mode;

void main() {
	float minx = dimension.x;
	float miny = dimension.y;
	float maxx = 0.;
	float maxy = 0.;
	
	for(float i = 0.; i <= dimension.x; i++)
	for(float j = 0.; j <= dimension.y; j++) {
		vec4 col = texture2D( gm_BaseTexture, vec2(i, j) / (dimension + 1.) );
		if(col.a == 0.) continue;
		
		minx = min(minx, i);
		miny = min(miny, j);
		maxx = max(maxx, i);
		maxy = max(maxy, j);
	}
	
	if(mode == 0) {
		float minx_h = floor(minx / 256.) / 255.;
		float minx_l =   mod(minx,  256.) / 255.;
		float miny_h = floor(miny / 256.) / 255.;
		float miny_l =   mod(miny,  256.) / 255.;
		gl_FragColor = vec4(minx_h, minx_l, miny_h, miny_l);
	} else {
		float maxx_h = floor(maxx / 256.) / 255.;
		float maxx_l =   mod(maxx,  256.) / 255.;
		float maxy_h = floor(maxy / 256.) / 255.;
		float maxy_l =   mod(maxy,  256.) / 255.;
		gl_FragColor = vec4(maxx_h, maxx_l, maxy_h, maxy_l);
	}
}
