cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    float uRadius;
    int uSamples;
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

float3 getBloom(float2 coord) {
    float3 color  = float3(0.0, 0.0, 0.0);
    int    weight = 0;
    float2 tx     = float2(1.0, 1.0) / uResolution;
    float2 scale  = tx * uRadius / float(uSamples);

    for (int i = 0; i < uSamples; i++) {
        float2 coord0 = coord + (float2( i,  i) * scale);
        float2 coord1 = coord + (float2(-i, -i) * scale);
        float2 coord2 = coord + (float2(-i,  i) * scale);
        float2 coord3 = coord + (float2( i, -i) * scale);

        color += gm_BaseTextureObject.Sample(gm_BaseTexture, coord0);
        color += gm_BaseTextureObject.Sample(gm_BaseTexture, coord1);
        color += gm_BaseTextureObject.Sample(gm_BaseTexture, coord2);
        color += gm_BaseTextureObject.Sample(gm_BaseTexture, coord3);

        weight++;
    }

    color /= float(weight) * 4.;
    return color;
}

void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    VertexShaderOutput input = _input;
    
    output.color = float4(getBloom(input.uv), 1.0);
}