#define	MATRIX_VIEW 					0
#define	MATRIX_PROJECTION 				1
#define	MATRIX_WORLD 					2
#define	MATRIX_WORLD_VIEW 				3
#define	MATRIX_WORLD_VIEW_PROJECTION 	4
#define	MATRICES_MAX					5

cbuffer gm_VSTransformBuffer
{
	float4x4 	gm_Matrices[MATRICES_MAX];
};

cbuffer gm_VSMaterialConstantBuffer
{
	bool 	gm_LightingEnabled;
	bool 	gm_VS_FogEnabled;
	float 	gm_FogStart;
	float 	gm_RcpFogRange;
};

#define	MAX_VS_LIGHTS					8

cbuffer gm_VSLightingConstantBuffer
{
	float4 gm_AmbientColour;							// rgb=colour, a=1
	float3 gm_Lights_Direction[MAX_VS_LIGHTS];			// normalised direction
	float4 gm_Lights_PosRange[MAX_VS_LIGHTS];			// X,Y,Z position,  W range
	float4 gm_Lights_Colour[MAX_VS_LIGHTS];				// rgb=colour, a=1
}

