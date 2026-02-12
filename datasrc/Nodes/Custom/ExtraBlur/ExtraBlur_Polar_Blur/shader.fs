cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    float uProgress;
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

float3 deform(float2 p, float t) {
    t *= 2.0;    
    p += 0.5 * sin(t * float2(1.1, 1.3) + float2(0.0, 0.5));

    float a = atan2(p.y, p.x);
    float r = length(p);
    
    float s = r * (1.0 + 0.5 * cos(t * 1.7));

    float2 uv = 0.1 * t + 0.05 * p.yx + 0.05 * float2(cos(t + a * 2.0), sin(t + a * 2.0)) / s;

    return gm_BaseTextureObject.Sample(gm_BaseTexture, 0.5 * uv).xyz;
}

void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    VertexShaderOutput input = _input;
    
    float2 fragCoord = input.uv * uResolution;
    float2 q = fragCoord / uResolution;
    float2 p = -1.0 + 2.0 * q;
    
    float3 col = float3(0.0, 0.0, 0.0);
    for (int i = 0; i < uIterations; i++) {
        float t = uProgress + float(i) * 0.0035; 
        col += deform(p, t);
    }
    col /= uIterations;
    
    output.color = float4(col, 1.0);
}