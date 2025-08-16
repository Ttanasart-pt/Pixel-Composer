#include "CommonPS.hlsl"

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

struct PS_out {
	float4 worldPosition  : SV_Target0;
	float4 viewPosition   : SV_Target1;
	float4 worldNormal    : SV_Target2;
	float4 viewNormal     : SV_Target3;
};

cbuffer MatData : register(b11) {
	float2 mat_texScale;
	float2 mat_texShift;

	int    mat_flip;
};

void main(in VS_out IN, out PS_out OUT) {
	float2 uv_coord = IN.TexCoord;
	if(mat_flip == 1) uv_coord.y = -uv_coord.y;
	uv_coord = frac(uv_coord * mat_texScale + mat_texShift);

	float4 mat_baseColor = gm_BaseTextureObject.Sample(gm_BaseTexture, uv_coord);
	if(mat_baseColor.a < 0.1) discard;

	float3 normal = normalize(IN.Normal);

	OUT.worldPosition = IN.WorldPosition;
	OUT.viewPosition  = float4(IN.ViewPosition, mat_baseColor.a);
	OUT.worldNormal   = float4(normal, mat_baseColor.a);
	OUT.viewNormal    = float4(IN.ViewNormal, mat_baseColor.a);
}
