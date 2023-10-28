#include "CommonVS.hlsl"

struct VS_in {
	float3 Position   : POSITION;
	float3 Normal     : NORMAL0;
	float4 Color      : COLOR0;
	float2 TexCoord   : TEXCOORD0;
	uint   InstanceID : SV_InstanceID;
};

struct VS_out {
	float4 Position : SV_POSITION;
	float3 Normal   : NORMAL0;
	float4 Color    : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

struct Transform {
	float4 position;
	float4 rotation;
	float4 scale;
	float4 reserved;
};

cbuffer Data : register(b10) {	
	Transform InstanceTransforms[128];
};

// float4x4 EulerToMatrix(float3 eulerAngles) {
//     float3 c = cos(eulerAngles);
//     float3 s = sin(eulerAngles);

//     float4x4 rotationMatrix;

//     rotationMatrix[0] = float4(c.y * c.z, -c.x * s.z + s.x * s.y * c.z, s.x * s.z + c.x * s.y * c.z, 0.0);
//     rotationMatrix[1] = float4(c.y * s.z, c.x * c.z + s.x * s.y * s.z, -s.x * c.z + c.x * s.y * s.z, 0.0);
//     rotationMatrix[2] = float4(-s.y, s.x * c.y, c.x * c.y, 0.0);
//     rotationMatrix[3] = float4(0.0, 0.0, 0.0, 1.0);

//     return rotationMatrix;
// }

void main(in VS_in IN, out VS_out OUT) {
	float3 position   = IN.Position.xyz;
	//float4x4 rotation = EulerToMatrix(InstanceTransforms[IN.InstanceID].rotation.xyz);
	float3 scale      = InstanceTransforms[IN.InstanceID].scale.xyz;

	//position = mul(rotation, float4(position, 1.)).xyz;
	position = position * scale;
	position = position + InstanceTransforms[IN.InstanceID].position.xyz;
	
	OUT.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(position.xyz, 1.0));
	OUT.Normal = mul(gm_Matrices[MATRIX_WORLD], float4(IN.Normal.xyz, 0.0));
	OUT.Color = IN.Color;
	OUT.TexCoord = IN.TexCoord;
}
