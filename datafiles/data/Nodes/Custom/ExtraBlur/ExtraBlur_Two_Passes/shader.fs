cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    int uRadius;
    int uAxis;
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
    
    float2 uv = input.uv;
    float2 tx = 1. / uResolution;
    float2 ax = float2(uAxis == 0, uAxis == 1);

    float4 color = float4(0, 0, 0, 0);

    for (int i = -uRadius; i <= uRadius; i++) {
        float2 offset = ax * i * tx;
        color += gm_BaseTextureObject.Sample(gm_BaseTexture, uv + offset);
    }

    output.color = color / (float(uRadius) * 2 + 1);
}