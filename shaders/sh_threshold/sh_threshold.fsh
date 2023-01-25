//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int mode;
uniform float thr;
uniform float smooth;

void main() {
	vec4 col  = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(mode == 0) {
		float bright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
		col.rgb = vec3(smooth == 0.? step(thr, bright) : smoothstep(thr - smooth, thr + smooth, bright));
	} else {
		col.a = smooth == 0.? step(thr, col.a) : smoothstep(thr - smooth, thr + smooth, col.a);
	}
	
    gl_FragColor = col;
}
