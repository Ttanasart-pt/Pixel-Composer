//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2      brightness;
uniform int       brightnessUseSurf;
uniform sampler2D brightnessSurf;

uniform vec2      contrast;
uniform int       contrastUseSurf;
uniform sampler2D contrastSurf;

void main() {
	float bri = brightness.x;
	if(brightnessUseSurf == 1) {
		vec4 _vMap = texture2D( brightnessSurf, v_vTexcoord );
		bri = mix(brightness.x, brightness.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float con = contrast.x;
	if(contrastUseSurf == 1) {
		vec4 _vMap = texture2D( contrastSurf, v_vTexcoord );
		con = mix(contrast.x, contrast.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    vec4 col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 col_b = col + vec4(bri, bri, bri, 0.0);
	vec4 col_bc = vec4(col_b.rgb * con, col_b.a);
	
	col_bc.rgb = vec3(dot(col_bc.rgb, vec3(0.2126, 0.7152, 0.0722)));
	
	gl_FragColor = col_bc;
}
