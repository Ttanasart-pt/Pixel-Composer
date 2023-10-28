#include "CommonVS.hlsl"

struct VS_in
{
	float3 Position   : POSITION;
	float3 Normal     : NORMAL0;
	float4 Color      : COLOR0;
	float2 TexCoord   : TEXCOORD0;
	uint   InstanceID : SV_InstanceID;
};

struct VS_out
{
	float4 Position : SV_POSITION;
	float3 Normal   : NORMAL0;
	float4 Color    : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

cbuffer Data : register(b10)
{
	float4 InstancePosition[4096];
};

void main(in VS_in IN, out VS_out OUT)
{
	float3 position = IN.Position.xyz + InstancePosition[IN.InstanceID].xyz;
	OUT.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(position.xyz, 1.0));
	OUT.Normal = mul(gm_Matrices[MATRIX_WORLD], float4(IN.Normal.xyz, 0.0));
	OUT.Color = IN.Color;
	OUT.TexCoord = IN.TexCoord;
}
