//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int use_mask;
uniform sampler2D mask;

uniform float brightness;
uniform float contrast;
uniform float hue;
uniform float sat;
uniform float val;

uniform vec4 blend;
uniform float blendAlpha;

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 0.0000000001;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
 }

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
    vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
    
	//contrast
	float cont = contrast * contrast;
	float c_factor = (1. + cont) / (1. - cont);
	vec4 col_c = c_factor * (col - .5) + .5;
	col_c = clamp(col_c, vec4(0.), vec4(1.));
	
	//brightness
	vec4 col_cb = col_c + vec4(brightness, brightness, brightness, 0.0);
	col_cb = clamp(col_cb, vec4(0.), vec4(1.));
	
	//hsv
	vec3 _hsv = rgb2hsv(col_cb.rgb);
	_hsv.x = clamp(_hsv.x + hue, -1., 1.);
	_hsv.z = clamp((_hsv.z + val) * (1. + sat * _hsv.y * .5), 0., 1.);
	_hsv.y = clamp(_hsv.y * (sat + 1.), 0., 1.);
	
	vec3 _col_cbh = hsv2rgb(_hsv);
	vec4 col_cbh = vec4(_col_cbh.r, _col_cbh.g, _col_cbh.b, col.a);
	col_cbh = clamp(col_cbh, vec4(0.), vec4(1.));
	
	//blend
	col_cbh.rgb = mix(col_cbh.rgb, blend.rgb, blendAlpha);
	
	//mask
	if(use_mask == 1) {
		vec4 mas = texture2D( mask, v_vTexcoord );
		mas.rgb *= mas.a;
		gl_FragColor = col_cbh * mas + col * (vec4(1.) - mas);
		gl_FragColor.a = col.a * mix(1., v_vColour.a, mas.r);
	} else {
		gl_FragColor = col_cbh;
		gl_FragColor.a = col.a * v_vColour.a;
	}
}
