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
	gl_FragColor = col;
	bool done = false;
	
	float shift_angle    = atan(shift.y, shift.x);
	float shift_distance = length(shift);
	float min_distance = 999.;
	
	if(bright(col) > 0.) {
		for(float i = 1.; i < height; i++) {
			for(float j = 0.; j < 32.; j++) {
				float ang = j * tauDiv;
				float added_distance = 1. + cos(abs(shift_angle - ang)) * shift_distance;
				
				vec2 shf = vec2( cos(ang),  sin(ang)) * (i * added_distance) / scale;
				
				vec2 pxs = v_vTexcoord + shf * pixelStep;
				vec4 sam = v_vColour * texture2D( gm_BaseTexture, pxs );
				if(bright(sam) < 1.) {
					float dist1 = i;
					min_distance = min(min_distance, dist1);
					break;
				}
			}
		}
		
		gl_FragColor = vec4(vec3(min_distance / height), col.a);
	}
}
