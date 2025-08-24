cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    float4 uColor;
};

Texture2D gm_BaseTextureObject : register(t0);
SamplerState gm_BaseTexture    : register(s0);

struct VertexShaderOutput {
    float4 pos      : SV_POSITION;
    float2 uv       : TEXCOORD0;
};

struct PixelShaderOutput {
    float4 color : SV_TARGET0;
};

void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    VertexShaderOutput input = _input;

    output.color = uColor;
}