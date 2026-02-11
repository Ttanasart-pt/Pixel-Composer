cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    float uHDR;
    int uSamples;
    float2 uScale;
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

#define ANGLE_SAMPLES (3 * uSamples)
#define OFFSET_SAMPLES (1 * uSamples)

float degs2rads(float degrees) {
    return degrees * 0.01745329251994329576923690768489;
}

float2 rot2D(float offset, float angle) {
    angle = degs2rads(angle);
    return float2(cos(angle) * offset, sin(angle) * offset);
}

float3 circle_blur(Texture2D sp, float2 uv, float2 scale) {
    float2 ps = (1.0 / uResolution) * scale;
    float3 col = float3(0.0, 0.0, 0.0);
    float accum = 0.0;
    
    for (int a = 0; a < 360; a += 360 / ANGLE_SAMPLES) {
        for (int o = 0; o < OFFSET_SAMPLES; ++o) {
            col += sp.Sample(gm_BaseTexture, uv + ps * rot2D(float(o), float(a))).rgb * float(o * o);
            accum += float(o * o);
        }
    }
    
    return col / accum;
}

float3 pseudo_tonemap(float3 col, float exposure) {
    float iHDR = 1.0 / uHDR;
    col = pow(col, float3(iHDR, iHDR, iHDR));
    return col;
}

void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    VertexShaderOutput input = _input;
    
    float2 uv = input.uv;
    float3 col = circle_blur(gm_BaseTextureObject, uv, uScale);
    col = pseudo_tonemap(col, 1.0);
    
    output.color = float4(col, 1.0);
}