attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour;
attribute vec3 in_Barycentric;

varying vec2  v_vTexcoord;
varying vec4  v_vColour;
varying vec3  v_vNormal;
varying vec3  v_barycentric;

varying vec4  v_worldPosition;
varying vec3  v_viewPosition;
varying vec3  v_viewNormal;
varying float v_cameraDistance;

uniform vec4 InstanceTransforms[2000];

uniform mat4  objectTransform;
uniform vec3  cameraPosition;
uniform float planeNear;
uniform float planeFar;
uniform int   InstanceID;

mat4 EulerToMatrix(vec3 eulerAngles) {
    vec3 c = cos(eulerAngles);
    vec3 s = sin(eulerAngles);

    mat4 rotationMatrix;

    rotationMatrix[0] = vec4(c.y * c.z, -c.x * s.z + s.x * s.y * c.z, s.x * s.z + c.x * s.y * c.z, 0.0);
    rotationMatrix[1] = vec4(c.y * s.z, c.x * c.z + s.x * s.y * s.z, -s.x * c.z + c.x * s.y * s.z, 0.0);
    rotationMatrix[2] = vec4(-s.y, s.x * c.y, c.x * c.y, 0.0);
    rotationMatrix[3] = vec4(0.0, 0.0, 0.0, 1.0);

    return rotationMatrix;
}

mat4 lookatMatrix(vec3 target, vec3 up) {
	vec3 zaxis = normalize(target);
	vec3 xaxis = cross(up, zaxis);

	if (length(xaxis) < 0.0001)
		return mat4(
			1.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0
		);

	       xaxis = normalize(xaxis);
	vec3 yaxis = cross(zaxis, xaxis);

	return mat4(
		xaxis.x, yaxis.x, zaxis.x, 0.0,
		xaxis.y, yaxis.y, zaxis.y, 0.0,
		xaxis.z, yaxis.z, zaxis.z, 0.0,
		    0.0,     0.0,     0.0, 1.0
	);
}

void main() {
    vec3 position = in_Position.xyz;
	vec3 normal   = in_Normal.xyz;

	vec4 tPos = InstanceTransforms[InstanceID * 4 + 0];
	vec4 tRot = InstanceTransforms[InstanceID * 4 + 1];
	vec4 tSca = InstanceTransforms[InstanceID * 4 + 2];
	vec4 tUpp = InstanceTransforms[InstanceID * 4 + 3];
	
	vec3 tran_pos = tPos.xyz;
	mat4 tran_rot = EulerToMatrix(tRot.xyz);
	vec3 tran_sca = tSca.xyz;
	vec3 tran_nor = tUpp.xyz;
	vec3 colr = vec3(tPos.w, tRot.w, tSca.w);

	position = (objectTransform * vec4(position, 1.)).xyz;
	position = (tran_rot        * vec4(position, 1.)).xyz;

	if(length(tran_nor) > 0.) {
		vec3 upNormal = normalize(tran_nor);
		mat4 lookat   = lookatMatrix(upNormal, vec3(0.0, 0.0, 1.0));

		position = (lookat * vec4(position, 1.)).xyz;
	}

	position *= tran_sca;
	position += tran_pos;
	
	normal   = (tran_rot * vec4(normal, 0.)).xyz;
	
    //////////////////////////////////// sh_d3d_default ////////////////////////////////////
    
    vec4 object_space_pos = vec4( position.x, position.y, position.z, 1.0);
    
    gl_Position     = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    v_worldPosition = gm_Matrices[MATRIX_WORLD] * object_space_pos;
	v_viewPosition  = (gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos).xyz;
	
    v_vColour    = in_Colour;
    v_vTexcoord  = in_TextureCoord;
	
	v_vNormal    = normalize(gm_Matrices[MATRIX_WORLD] * vec4(normal, 0.)).xyz;
	v_viewNormal = normalize(gm_Matrices[MATRIX_WORLD_VIEW] * vec4(normal, 0.)).xyz;
	
	float depthRange = abs(planeFar - planeNear);
	float ndcDepth   = (gl_Position.z - planeNear) / depthRange;
	v_cameraDistance = ndcDepth * 0.5 + 0.5;
	
	v_barycentric = in_Barycentric;
}
