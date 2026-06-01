cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    int uBlendMode;
    float uSeed;
    float uIntensity;
    float uMean;
    float uVarience;
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

float3 channel_mix(float3 a, float3 b, float3 w) {
    return float3(lerp(a.r, b.r, w.r), lerp(a.g, b.g, w.g), lerp(a.b, b.b, w.b));
}

float gaussian(float z, float u, float o) {
    return (1.0 / (o * sqrt(2.0 * 3.1415))) * exp(-(((z - u) * (z - u)) / (2.0 * (o * o))));
}

float3 madd(float3 a, float3 b, float w) {
    return a + a * b * w;
}

float3 screen(float3 a, float3 b, float w) {
    return lerp(a, float3(1, 1, 1) - (float3(1, 1, 1) - a) * (float3(1, 1, 1) - b), w);
}

float3 overlay(float3 a, float3 b, float w) {
    return lerp(a, channel_mix(
        2.0 * a * b,
        float3(1, 1, 1) - 2.0 * (float3(1, 1, 1) - a) * (float3(1, 1, 1) - b),
        step(float3(.5, .5, .5), a)
    ), w);
}

float3 soft_light(float3 a, float3 b, float w) {
    return lerp(a, pow(a, pow(float3(2, 2, 2), 2.0 * (float3(.5, .5, .5) - b))), w);
}

void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    VertexShaderOutput input = _input;
    
    float2 uv = input.uv;
    output.color = gm_BaseTextureObject.Sample(gm_BaseTexture, uv);
    
    float t     = uSeed;
    float seed  = dot(uv, float2(12.9898, 78.233));
    float noise = frac(sin(seed) * 43758.5453 + t);
    noise = gaussian(noise, float(uMean), float(uVarience) * float(uVarience));
    
    float w = float(uIntensity);
    
    float3 grain = float3(noise, noise, noise) * (1.0 - output.color.rgb);
    
         if(uBlendMode == 0) output.color.rgb += grain * w;
    else if(uBlendMode == 1) output.color.rgb = screen(output.color.rgb, grain, w);
    else if(uBlendMode == 2) output.color.rgb = overlay(output.color.rgb, grain, w);
    else if(uBlendMode == 3) output.color.rgb = soft_light(output.color.rgb, grain, w);
    else if(uBlendMode == 4) output.color.rgb = max(output.color.rgb, grain * w);
}