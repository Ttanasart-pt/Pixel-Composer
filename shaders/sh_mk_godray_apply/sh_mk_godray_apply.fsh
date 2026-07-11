varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform sampler2D raySurface;

uniform vec2      intensity;
uniform int       intensityUseSurf;
uniform sampler2D intensitySurf;

void main() {
	#region params
		float ints = intensity.x;
		if(intensityUseSurf == 1) {
			vec4 _vMap = texture2D( intensitySurf, v_vTexcoord );
			ints = mix(intensity.x, intensity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
		
	vec4 base  = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 light = texture2D(raySurface, v_vTexcoord);
	
	light.a = max(light.a, 0.);
	light.rgb *= light.a;
	
	gl_FragColor = base + light * ints;
}