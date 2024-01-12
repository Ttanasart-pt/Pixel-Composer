varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float smoothness;
uniform float strength;
uniform float amplitude;

void main() {
	vec2 uv  = v_vTexcoord;
	     uv *= 1.0 - uv.yx;
    float vig = uv.x * uv.y * smoothness;
    
    vig = pow(vig, amplitude);
	vig = clamp(vig, 0., 1.);
	
	vec4 samp = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = vec4(samp.rgb * (1. - ((1. - vig) * strength)), samp.a);
}
