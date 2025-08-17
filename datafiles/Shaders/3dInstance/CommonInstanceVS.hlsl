#ifndef __COMMONINSVS_HLSL__
#define __COMMONINSVS_HLSL__

cbuffer SceneData : register(b11) {	
	float4x4 objectTransform;
	float planeNear;
	float planeFar;
}

float4x4 EulerToMatrix(float3 eulerAngles) {
    float3 c = cos(eulerAngles);
    float3 s = sin(eulerAngles);

    float4x4 rotationMatrix;

    rotationMatrix[0] = float4(c.y * c.z, -c.x * s.z + s.x * s.y * c.z, s.x * s.z + c.x * s.y * c.z, 0.0);
    rotationMatrix[1] = float4(c.y * s.z, c.x * c.z + s.x * s.y * s.z, -s.x * c.z + c.x * s.y * s.z, 0.0);
    rotationMatrix[2] = float4(-s.y, s.x * c.y, c.x * c.y, 0.0);
    rotationMatrix[3] = float4(0.0, 0.0, 0.0, 1.0);

    return rotationMatrix;
}

float4x4 lookatMatrix(float3 target, float3 up) {
	float3 zaxis = normalize(target);
	float3 xaxis = cross(up, zaxis);

	if (length(xaxis) < 0.0001)
		return float4x4(
			1.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0
		);

	       xaxis = normalize(xaxis);
	float3 yaxis = cross(zaxis, xaxis);

	return float4x4(
		xaxis.x, yaxis.x, zaxis.x, 0.0,
		xaxis.y, yaxis.y, zaxis.y, 0.0,
		xaxis.z, yaxis.z, zaxis.z, 0.0,
		    0.0,     0.0,     0.0, 1.0
	);
}

#endif // __COMMONINSVS_HLSL__