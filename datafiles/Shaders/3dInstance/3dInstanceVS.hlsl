#include "CommonVS.hlsl"
#include "CommonInstanceVS.hlsl"

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

