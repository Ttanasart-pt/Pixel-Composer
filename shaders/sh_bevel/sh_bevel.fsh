//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  scale;
uniform vec2  shift;
uniform float height;

#define TAU   6.28318

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a;
}

void main() {
	vec2 pixelStep = 1. / dimension;
    float tauDiv = TAU / 32.;
	
    vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 col1;
	gl_FragColor = col;
	bool done = false;
	
	float b0 = bright(col);
	float shift_angle    = atan(shift.y, shift.x);
	float shift_distance = length(shift);
	float slope_distance = height * b0;
	float max_distance = height;
	
	if(b0 == 0.) return;
	
	float b1 = b0;
	float ang, added_distance, _b1;
	vec2 shf, pxs;
	
	for(float i = 1.; i < 16.; i++) {
		if(i >= height) break;
		for(float j = 0.; j < 32.; j++) {
			ang = j * tauDiv;
			added_distance = 1. + cos(abs(shift_angle - ang)) * shift_distance;
				
			shf = vec2( cos(ang),  sin(ang)) * (i * added_distance) / scale;
			pxs = v_vTexcoord + shf * pixelStep;
				
			if(pxs.x < 0. || pxs.y < 0. || pxs.x > 1. || pxs.y > 1.) 
				_b1 = 0.;
			else {
				col1 = texture2D( gm_BaseTexture, pxs );
				_b1 = bright(col1);
			}
				
			if(_b1 < b1) {
				slope_distance = min(slope_distance, i);
				max_distance = min(max_distance, (b0 - _b1) * height);
				b1 = min(b1, _b1);
				
				i = height;
				break;
			}
		}
	}
		
	if(max_distance == 0.)
		gl_FragColor = vec4(vec3(b0), col.a);
	else {
		float sl = clamp(mix(b1, b0, slope_distance / max_distance), 0., 1.);
		gl_FragColor = vec4(vec3(sl), col.a);
		//gl_FragColor = vec4(slope_distance / height, max_distance / height, sl, col.a);
		//gl_FragColor = vec4(b0, b1, sl, col.a);
	}
}
