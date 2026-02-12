#define MATRIX_WORLD                 0
#define MATRIX_WORLD_VIEW            1
#define MATRIX_WORLD_VIEW_PROJECTION 2

cbuffer Matrices : register(b0) {
    float4x4 gm_Matrices[3];
};

struct VertexShaderInput {
    float3 pos      : POSITION;
    float3 color    : COLOR0;
    float2 uv       : TEXCOORD0;
};

struct VertexShaderOutput {
    float4 pos      : SV_POSITION;
    float2 uv       : TEXCOORD0;
};

void main(in VertexShaderInput input, out VertexShaderOutput output) {
    output.pos  = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(input.pos, 1.0f));
    output.uv   = input.uv;   
}