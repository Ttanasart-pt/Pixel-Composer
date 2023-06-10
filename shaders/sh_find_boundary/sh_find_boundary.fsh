//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 minn;
uniform int  mode;

uniform sampler2D texture;

void main() {
	//float minx = dimension.x;
	//float miny = dimension.y;
	//float maxx = 0.;
	//float maxy = 0.;
	
	//for(float i = 0.; i <= dimension.x; i++)
	//for(float j = 0.; j <= dimension.y; j++) {
	//	vec4 col = texture2D( gm_BaseTexture, vec2(i, j) / (dimension + 1.) );
	//	if(col.r == 0.) continue;
		
	//	minx = min(minx, i);
	//	miny = min(miny, j);
	//	maxx = max(maxx, i);
	//	maxy = max(maxy, j);
	//}
	
	float _w = dimension.x;
	float _h = dimension.y;
	vec4 col;
	float i, j;
	
	if(mode == 0) {
		float miny = 0.;
		for( i = miny; i < _h; i++ )
		for( j = 0.; j < _w; j++ ) {
			col = texture2D( texture, vec2(j, i) / dimension);
			if(col.r > 0.) {
				miny = i;
				i = _h;
				break;
			}
		}
	
		float minx = 0.;
		for( j = 0.; j < _w; j++ ) 
		for( i = miny; i < _h; i++ ) {
			col = texture2D( texture, vec2(j, i) / dimension);
			if(col.r > 0.) {
				minx = j;
				j = _w;
				break;
			}
		}
	
		float minx_h = floor(minx / 256.) / 255.;
		float minx_l =   mod(minx,  256.) / 255.;
		float miny_h = floor(miny / 256.) / 255.;
		float miny_l =   mod(miny,  256.) / 255.;
		gl_FragColor = vec4(minx_h, minx_l, miny_h, miny_l);
	} else {
		float maxy = _h;
		for( i = maxy; i >= minn.y; i-- )
		for( j = 0.; j < _w; j++ ) {
			col = texture2D( texture, vec2(j, i) / dimension);
			if(col.r > 0.) {
				maxy = i;
				i = 0.;
				break;
			}
		}
		
		float maxx = 0.;
		for( j = _w; j >= minn.x; j-- ) 
		for( i = minn.y; i < maxy; i++ ) {
			col = texture2D( texture, vec2(j, i) / dimension);
			if(col.r > 0.) {
				maxx = j;
				j = 0.;
				break;
			}
		}
	
		float maxx_h = floor(maxx / 256.) / 255.;
		float maxx_l =   mod(maxx,  256.) / 255.;
		float maxy_h = floor(maxy / 256.) / 255.;
		float maxy_l =   mod(maxy,  256.) / 255.;
		gl_FragColor = vec4(maxx_h, maxx_l, maxy_h, maxy_l);
	}
}
