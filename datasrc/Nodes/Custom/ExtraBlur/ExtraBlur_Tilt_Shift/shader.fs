cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    float  uRadius;
    float2 uPosition;
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

float4 blur (float2 uv, float radius) {
    float2 tx     = 1.0 / uResolution;
    float4 color  = float4(0.0, 0.0, 0.0, 0.0);
    float  total  = 0.0;
    float  radScal = radius / uRadius;
    
    for(float i = -uRadius; i <= uRadius; i += 1.0)
    for(float j = -uRadius; j <= uRadius; j += 1.0) {
        float2 offset = float2(i, j) * radScal * tx;
        float  weight = max(0., 1.0 - length(offset) / radius);
        
        float2 coord = uv + offset;
        color += gm_BaseTextureObject.Sample(gm_BaseTexture, coord) * weight;
        total += weight;
    }

    return color / total;
}

void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    VertexShaderOutput input = _input;

    float2 uv  = input.uv;
    float2 tx  = float2(1.0 / uResolution.x, 1.0 / uResolution.y);
    float2 cen = uPosition * tx;

    float  radius = uRadius * abs(uv.y - cen.y);
    output.color = blur(uv, radius);
}