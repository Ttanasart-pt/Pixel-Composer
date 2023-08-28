varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define MAX_SAMPLE 256

uniform sampler2D vPosition;
uniform sampler2D vNormal;
uniform float     radius;
uniform float     bias;
uniform float     strength;
uniform vec3      cameraPosition;

uniform mat4 projMatrix;

float seed = 234234.453;
float rand(vec2 pos) {
    float value = dot(pos, vec2(12.9898, 78.233));
    value = fract(sin(value + seed) * 43758.5453);
	seed++;
    return value;
}

float rand(vec3 pos) {
    float value = dot(pos, vec3(12.9898, 78.233, 45.164));
    value = fract(sin(value + seed) * 43758.5453);
	seed++;
    return value;
}

void main() {
	vec3  cPosition = texture2D( vPosition, v_vTexcoord ).rgb;
	vec3  cNormal   = texture2D( vNormal,   v_vTexcoord ).rgb;
	cNormal = normalize(cNormal);
	
	gl_FragColor = vec4(0.);
	
	float occluded   = 0.;
	float raysTotal  = float(MAX_SAMPLE);
	
	vec3 rvec      = vec3(rand(v_vTexcoord), rand(v_vTexcoord), rand(v_vTexcoord)) * 2. - 1.;
	vec3 tangent   = normalize(rvec - cNormal * dot(rvec, cNormal));
	vec3 bitangent = cross(cNormal, tangent);
	mat3 tbn       = mat3(tangent, bitangent, cNormal);	//matrix to align the deviated vector to the normal hemisphere.
	
	for(int i = 0; i < MAX_SAMPLE; i++ ) {
		vec3  sNormal = tbn * vec3( rand(v_vTexcoord) * 2. - 1., rand(v_vTexcoord) * 2. - 1., rand(v_vTexcoord) ); // genetate random point inside the hemisphere.
		float scale   = length(sNormal);
		scale   = mix(0.1, 1.0, scale * scale);
		sNormal = normalize(sNormal) * scale;
		
		vec3  wPosition    = cPosition + sNormal * radius; //add random vector to current world position.
		float vecToCamDist = distance(wPosition, cameraPosition);
		
		vec4 projPos = projMatrix * vec4(wPosition, 1.);
		projPos.xyz /= projPos.w;
		projPos      = (projPos + 1.) / 2.;		//project new world position to view space.
		
		vec3  sPosition    = texture2D( vPosition, projPos.xy ).xyz;	//sample depth at the new point in the view space.
		if(sPosition == vec3(0.)) continue;
		
		float geoToCamDist = distance(sPosition, cameraPosition);
		
		if(distance(sPosition, cPosition) < radius)
		if(vecToCamDist - bias > geoToCamDist)
			occluded++;
	}
	
    gl_FragColor = vec4(vec3(1. - occluded / raysTotal * strength), 1.);
	//gl_FragColor = vec4(vec3(distance(cPosition, cameraPosition) / 10.), 1.);
}
