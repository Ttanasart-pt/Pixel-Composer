cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    float uRadius;
    int  uIterations;
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

float2 Sample(inout float2 r) {
    r = frac(r * float2(33.3983, 43.4427));
    return r - 0.5;
}

#define HASHSCALE 443.8975
float2 Hash22(float2 p) {
    float3 p3 = frac(float3(p.x, p.y, p.x) * HASHSCALE);
    p3 += dot(p3, p3.yzx + 19.19);
    return frac(float2((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y));
}

float3 Blur(float2 uv, float radius) {
    float2 tx     = 1.0 / uResolution;
    float2 circle = float2(radius, radius) * tx;
    float2 random = Hash22(uv);

    float3 acc = float3(0.0, 0.0, 0.0);
    for (int i = 0; i < uIterations; i++) {
        float2 _uv = uv + circle * Sample(random);
        acc += gm_BaseTextureObject.Sample(gm_BaseTexture, _uv).xyz;
    }

    return acc / float(uIterations);
}

void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    VertexShaderOutput input = _input;
    
    output.color = float4(Blur(input.uv, uRadius), 1.0);
}