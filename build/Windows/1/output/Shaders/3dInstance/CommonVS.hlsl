#ifndef __COMMONVS_HLSL__
#define __COMMONVS_HLSL__

#define MATRIX_WORLD                 0
#define MATRIX_WORLD_VIEW            1
#define MATRIX_WORLD_VIEW_PROJECTION 2

cbuffer Matrices : register(b0)
{
	float4x4 gm_Matrices[3];
};

#endif // __COMMONVS_HLSL__
