//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D texMap;
uniform vec2 dimension;

uniform sampler2D depthMap;
uniform vec2 depthDimension;

uniform float depth;

uniform vec3 cameraPos;
uniform vec3 cameraUp;
uniform vec3 cameraRight;

bool rayHitCube(vec3 rayStart, vec3 rayDirection, vec3 cubeCenter, vec3 cubeSpan) {
	// Calculate the minimum and maximum bounds of the cube
    vec3 cubeMin = cubeCenter - cubeSpan * 0.5;
    vec3 cubeMax = cubeCenter + cubeSpan * 0.5;

    // Calculate the inverse direction of the ray
    vec3 invRayDir = 1.0 / rayDirection;

    // Calculate the intersection distances with the cube's bounding planes
    vec3 tMin = (cubeMin - rayStart) * invRayDir;
    vec3 tMax = (cubeMax - rayStart) * invRayDir;

    // Find the largest entry among the intersection distances
    vec3 tNear = min(tMin, tMax);
    vec3 tFar = max(tMin, tMax);

    // Find the largest entry among the intersection distances
    float t0 = max(max(tNear.x, tNear.y), tNear.z);
    float t1 = min(min(tFar.x, tFar.y), tFar.z);

    // Check if there is a valid intersection
    return t0 <= t1;
}

void main() {
	vec3 cameraPixelPosition = cameraPos + (v_vTexcoord.x - 0.5) * cameraRight + (v_vTexcoord.y - 0.5) * cameraUp;
	vec3 cameraForward = -cameraPos;
	
	float minDist = 99999.;
	vec2 hitPos   = vec2(0.);
	vec3 cubeSpan = vec3(.5 / dimension.x, .5 / dimension.y, .5 / dimension.x);
	
	for(float i = 0.; i < dimension.x; i++)
	for(float j = 0.; j < dimension.y; j++) {
		vec4 _dsample = texture2D( gm_BaseTexture, vec2(i, j) / dimension );
		float _d = depth * (_dsample.x + _dsample.y + _dsample.z) / 3.;
		
		vec3 cubePos = vec3(i, j, _d);
		
		float dist = distance(cameraPixelPosition, cubePos);
		if(dist <= minDist) 
		if(rayHitCube(cameraPixelPosition, cameraForward, cubePos, cubeSpan)) {
			minDist = dist;
			hitPos  = vec2(i, j) / dimension;
		}
		
		cubePos = vec3(i, j, -_d);
		
		dist = distance(cameraPixelPosition, cubePos);
		if(dist <= minDist) 
		if(rayHitCube(cameraPixelPosition, cameraForward, cubePos, cubeSpan)) {
			minDist = dist;
			hitPos  = vec2(i, j) / dimension;
		}
	}
	
	if(minDist == 99999.)
		gl_FragColor = vec4(0.);
	else
		gl_FragColor = texture2D( gm_BaseTexture, hitPos );
}

