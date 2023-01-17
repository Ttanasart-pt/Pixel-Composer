//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define pi1 3.14159
#define pi2 1.57079

uniform vec2  dimension;

uniform sampler2D normalMap;
uniform float normalHeight;

uniform vec3  ambiance;
uniform int	  lightType;
uniform vec4  lightPosition;
uniform vec3  lightColor;
uniform float lightIntensity;

void main() {
    vec4 base_color = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	vec3 normal		= normalize(texture2D( normalMap, v_vTexcoord ).rgb * -2.0 + 1.0) * normalHeight;
	float aspect	= dimension.x / dimension.y;
	
	vec3 result		= ambiance * base_color.rgb;
	
	vec3 lightPos = vec3(lightPosition.x / dimension.x, lightPosition.y / dimension.y, lightPosition.z);
	float attenuation = lightIntensity;
	
	float range = lightPosition.a / max(dimension.x, dimension.y);
	vec3 lightDir;
	
	if(lightType == 0) {
		attenuation *= max(1. - sqrt( pow(v_vTexcoord.x - lightPos.x, 2.) + pow((v_vTexcoord.y - lightPos.y) / aspect, 2.)) / range, 0.);
		lightDir = normalize(lightPos - vec3(v_vTexcoord.x, v_vTexcoord.y, 0.)); 
	} else {
		lightDir = normalize(lightPos - vec3(0.5, 0.5, 0.)); 
	}
	
	float d = max(dot(normal, lightDir), 0.0);
	vec3 diffuse = d * lightColor * base_color.rgb * attenuation;
	result += diffuse;
	result.r = min(result.r, base_color.r);
	result.g = min(result.g, base_color.g);
	result.b = min(result.b, base_color.b);
	
	gl_FragColor = vec4(result, base_color.a);
}
