#include "CommonVS.hlsl"

struct VS_in {
	float3 Position   : POSITION;
	float3 Normal     : NORMAL0;
	float4 Color      : COLOR0;
	float2 TexCoord   : TEXCOORD0;
	uint   InstanceID : SV_InstanceID;
};

struct VS_out {
	float4 Position       : SV_POSITION;
	float4 WorldPosition  : TEXCOORD1;
	float3 ViewPosition   : TEXCOORD2;

	float3 Normal         : NORMAL0;
	float3 ViewNormal     : TEXCOORD4;

	float4 Color          : COLOR0;
	float2 TexCoord       : TEXCOORD0;

	float  cameraDistance : TEXCOORD3;
	uint   InstanceID     : SV_InstanceID;
};

struct Transform {
	float4 position;
	float4 rotation;
	float4 scale;
	float4 upNormal;
};

cbuffer Data : register(b10) {	
	Transform InstanceTransforms[1024];
};

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

void main(in VS_in IN, out VS_out OUT) {
	float3 position   = IN.Position.xyz;
	float3 normal     = IN.Normal.xyz;

	Transform transform = InstanceTransforms[IN.InstanceID];
	float3   tran_pos = transform.position.xyz;
	float4x4 tran_rot = EulerToMatrix(transform.rotation.xyz);
	float3   tran_sca = transform.scale.xyz;
	float3   tran_nor = transform.upNormal.xyz;
	float3   colr = float3(transform.position.w, transform.rotation.w, transform.scale.w);

	position = mul(objectTransform, float4(position, 1.)).xyz;
	position = mul(tran_rot, float4(position, 1.)).xyz;

	if(length(tran_nor) > 0.) {
		float3 upNormal = normalize(tran_nor);
		float4x4 lookat = lookatMatrix(upNormal, float3(0.0, 0.0, 1.0));

		position = mul(lookat, float4(position, 1.)).xyz;
	}

	position *= tran_sca;
	position += tran_pos;

	normal   = mul(tran_rot, float4(normal, 0.)).xyz;
	
	OUT.Position       = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(position.xyz, 1.0));
	OUT.WorldPosition  = mul(gm_Matrices[MATRIX_WORLD], float4(position, 1.0));
	OUT.ViewPosition   = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(position.xyz, 1.0));

	OUT.Normal         = mul(gm_Matrices[MATRIX_WORLD], float4(normal, 0.0));
	OUT.ViewNormal     = mul(gm_Matrices[MATRIX_WORLD_VIEW], float4(normal, 0.0)).xyz;

	OUT.Color          = IN.Color * float4(colr, 1.0);
	OUT.TexCoord       = IN.TexCoord;
	OUT.InstanceID     = IN.InstanceID;

	float depthRange = abs(planeFar - planeNear);
	float ndcZ = (OUT.ViewPosition.z - planeNear) / depthRange;
	OUT.cameraDistance = ndcZ * .5 + .5;
}

