varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform vec2      intensity;
uniform int       intensityUseSurf;
uniform sampler2D intensitySurf;

uniform sampler2D mask;
uniform int       useMask;

uniform float rotation;
uniform vec3  scale;
uniform int   renormalize;

void main() {
	#region params
		float its = intensity.x;
		if(intensityUseSurf == 1) {
			vec4 _vMap = texture2D( intensitySurf, v_vTexcoord );
			its = mix(intensity.x, intensity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
	#endregion
	
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	vec3 norm = base.rgb;
	
	vec3 offs = vec3(.5, .5, 0.);
	norm -= offs;
	norm *= its;
	
	norm *= scale;
	
	float ang = radians(rotation);
	norm.xy  *= mat2(cos(ang), - sin(ang), sin(ang), cos(ang));
	norm     += offs;
	
	if(useMask == 1) {
		vec4  mskS = texture2D(mask, v_vTexcoord);
		float mskA = (mskS.r + mskS.g + mskS.b) / 3. * mskS.a;
		norm = mix(base.rgb, norm, mskA);
	}
	
	if(renormalize == 1) norm = normalize(norm);
	
	gl_FragColor = vec4(norm, base.a);
}