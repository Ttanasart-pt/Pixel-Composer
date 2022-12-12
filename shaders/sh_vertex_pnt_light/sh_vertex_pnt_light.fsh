//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying float v_vNormalLight;

uniform vec3  u_AmbientLight;
uniform vec3  u_LightColor;
uniform float u_LightIntensity;

void main() {
	vec4 dif = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 lig = dif * (u_LightIntensity * vec4(u_LightColor, 1.));
	vec4 amb = dif * vec4(u_AmbientLight, 1.);
	float intensity = min(v_vNormalLight * u_LightIntensity, 1.);
	vec4 clr = mix(amb, lig, intensity);
	clr.a = dif.a;
    gl_FragColor = clr;
}
