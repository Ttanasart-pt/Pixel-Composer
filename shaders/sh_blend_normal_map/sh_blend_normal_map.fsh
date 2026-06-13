varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform int   blendMode;
uniform float intensity;
uniform int   renormalize;

uniform sampler2D surface_1;
uniform int  surface_1_use;

uniform vec2  position_1;
uniform vec2  anchor_1;
uniform float rotation_1;
uniform vec2  scale_1;

uniform sampler2D surface_2;
uniform int  surface_2_use;

uniform vec2  position_2;
uniform vec2  anchor_2;
uniform float rotation_2;
uniform vec2  scale_2;

uniform sampler2D mask;
uniform int  mask_use;

void main() {
	mat2 rot1 = mat2(cos(rotation_1), sin(rotation_1), -sin(rotation_1), cos(rotation_1));
	vec2 tx1  = (v_vTexcoord - anchor_1) * rot1 / scale_1 + anchor_1 - position_1 / dimension;
	vec4  s1 = texture2D(surface_1, tx1);
	
	gl_FragColor = s1;
	
	if(surface_2_use == 0) return;
	
	mat2 rot2 = mat2(cos(rotation_2), sin(rotation_2), -sin(rotation_2), cos(rotation_2));
	vec2 tx2  = (v_vTexcoord - anchor_2) * rot2 / scale_2 + anchor_2 - position_2 / dimension;
	vec4  s2 = texture2D(surface_2, tx2);
	
	if(s2.a == 0.) return;
	
	vec3 offs = vec3(.5, .5, 1.);
	vec3 n1 = s1.rgb - offs;
	vec3 n2 = s2.rgb - offs;
	vec3 nr = n1;
	
	     if(blendMode == 0) nr = n1 + n2;
	else if(blendMode == 1) nr = max(n1, n2);
	// 2
	else if(blendMode == 3) nr = n1 - n2;
	else if(blendMode == 4) nr = min(n1, n2);
	// 5
	else if(blendMode == 6) nr = n2;
	
	nr = mix(n1, nr, intensity);
	nr += offs;
	
	if(mask_use == 1) {
		vec4  mskS = texture2D(mask, v_vTexcoord);
		float mskA = (mskS.r + mskS.g + mskS.b) / 3. * mskS.a;
		nr = mix(n1, nr, mskA);
	}
	
	if(renormalize == 1) nr = normalize(nr);
	gl_FragColor = vec4(nr, 1.);
}