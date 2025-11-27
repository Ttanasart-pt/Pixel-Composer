#define TAU 6.28318530718

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform sampler2D normalMap;
uniform sampler2D heightMap;
uniform int   useHeightMap;
uniform float normalHeight;

uniform vec4  ambiance;
uniform int	  lightType;
uniform vec4  lightPosition;
uniform vec4  lightPosition2;

uniform float lightIntensity;
uniform vec4  lightColor;
uniform vec4  lightColor2;

uniform float spotRadius;

vec3 closestPointOnLine(vec3 P, vec3 A, vec3 B, out float t) {
    vec3 AP = P - A;
    vec3 AB = B - A;
    t = dot(AP, AB) / dot(AB, AB);
    t = clamp(t, 0.0, 1.0);
    return A + t * AB;
}

void main() {
	float aspect = dimension.x / dimension.y;
	vec3  normal = texture2D( normalMap, v_vTexcoord ).rgb * -2.0 + 1.0;
	normal = normalize(normal);
	
	vec3  hsamp = texture2D( heightMap, v_vTexcoord ).rgb;
	float h = useHeightMap == 1? (hsamp.r + hsamp.g + hsamp.b) / 3. * normalHeight : 0.;
	
	vec3 lightPos = vec3(lightPosition.x / dimension.x, lightPosition.y / dimension.y, lightPosition.z);
	float attenuation = lightIntensity;
	
	float range = lightPosition.a / max(dimension.x, dimension.y);
	vec3  curr  = vec3(v_vTexcoord.x, v_vTexcoord.y, h);
	vec3  lightDir;
	vec3  diffuse;
	vec4  lightClr = lightColor;
	
	if(lightType == 0) {
		vec3 lig = lightPos - curr;
		lightDir = normalize(lig); 
		attenuation *= 1. - length(lig) / range;
		
	} else if(lightType == 1) {
		lightDir = normalize(lightPos - vec3(0.5, 0.5, 0.)); 
		lightDir.x *= -1.;
		
	} else if(lightType == 2) {
		float t = 0.;
		vec3 lightPos2 = vec3(lightPosition2.x / dimension.x, lightPosition2.y / dimension.y, lightPosition2.z);
		vec3 lightPosC = closestPointOnLine(curr, lightPos, lightPos2, t);
		
		vec3 lig = lightPosC - curr;
		lightDir = normalize(lig); 
		attenuation *= 1. - length(lig) / range;
		lightClr = mix(lightColor, lightColor2, t);
		
	} else if(lightType == 3) {
		vec3 lightPos2 = vec3(lightPosition2.x / dimension.x, lightPosition2.y / dimension.y, lightPosition2.z);
		vec3 spotDir   = normalize(lightPos - lightPos2);
		vec3 lig       = lightPos - curr;
		
		lightDir     = normalize(lig); 
		attenuation *= 1. - acos(dot(spotDir, lightDir)) / range;
	}
	
	float d = max(dot(normal, lightDir), 0.0);
	diffuse = d * lightClr.rgb * lightClr.a * attenuation;
	gl_FragColor = vec4(diffuse, 1.);
}
