//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int mode;
uniform float thr;

void main() {
	vec4 col  = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(mode == 0) {
		float bright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
		if(bright > thr) 
			col.rgb = vec3(1.);
		else 
			col.rgb = vec3(0.);
	} else {
		col.a = col.a > thr? 1. : 0.;
	}
	
    gl_FragColor = col;
}
