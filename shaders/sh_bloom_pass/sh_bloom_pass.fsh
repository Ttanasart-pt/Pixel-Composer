varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2      tolerance;
uniform int       toleranceUseSurf;
uniform sampler2D toleranceSurf;

uniform int useMask;
uniform sampler2D mask;

void main() {
	float tol = tolerance.x;
	if(toleranceUseSurf == 1) {
		vec4 _vMap = texture2D( toleranceSurf, v_vTexcoord );
		tol = mix(tolerance.x, tolerance.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	float bright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
	if(bright > tol)
		gl_FragColor = col;
	else 
		gl_FragColor = vec4(vec3(0.), 1.);
		
	if(useMask == 1) 
		gl_FragColor = col * texture2D( mask, v_vTexcoord );
}
