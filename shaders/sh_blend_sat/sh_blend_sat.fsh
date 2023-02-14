//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int tile_type;

uniform int useMask;
uniform int preserveAlpha;
uniform sampler2D mask;
uniform sampler2D fore;
uniform float opacity;

float sampleMask() {
	if(useMask == 0) return 1.;
	vec4 m = texture2D( mask, v_vTexcoord );
	return (m.r + m.g + m.b) / 3. * m.a;
}

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
	vec4 _col0 = texture2D( gm_BaseTexture, v_vTexcoord );
	vec3 _hsv0 = rgb2hsv(_col0.rgb);
	
	vec2 fore_tex = v_vTexcoord;
	if(tile_type == 0)
		fore_tex = v_vTexcoord;
	else if(tile_type == 1)
		fore_tex = fract(v_vTexcoord * dimension);
	
	vec4 _col1 = texture2D( fore, fore_tex );
	vec3 _hsv1 = rgb2hsv(_col1.rgb);
	
	_hsv0.y = mix(_hsv0.y, _hsv1.y, _col1.a * opacity * sampleMask());
	
	vec4 res = vec4(hsv2rgb(_hsv0), _col0.a);
	if(preserveAlpha == 1) res.a = _col0.a;
	
    gl_FragColor = res;
}
