cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    float uRadius;
    int uSamples;
    int uSeed;
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

#define DIFF 4.0

#define pi 3.14159265359
#define pi2 2.0 * pi

uint hash(inout uint x) {
    x ^= x >> 16;
    x *= 0x7feb352dU;
    x ^= x >> 15;
    x *= 0x846ca68bU;
    x ^= x >> 16;
    
    return x;
}

float randomFloat(inout uint state) {
    return float(hash(state)) / 4294967296.0;
} 

float2 randomDir(inout uint state) {
    float z = randomFloat(state) * 2.0 - 1.0;
    float a = randomFloat(state) * pi2;
    float r = sqrt(1.0f - z * z);
    float x = r * cos(a);
    float y = r * sin(a);
    return float2(x, y);
}

void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    VertexShaderOutput input = _input;
    float2 uv = input.uv;

    float2 tx     = 1.0 / uResolution.x;
    float2 radius = uRadius * tx;
    float  diff   = DIFF / 255.0;
    float3 result = float3(0.0, 0.0, 0.0);
    uint   seed   = uSeed;
    float  totalWeight = 0.0;
    float3 pixel  = gm_BaseTextureObject.Sample(gm_BaseTexture, uv).xyz;                  

    for (int i = 0; i < uSamples; i++) {
        float2 dir = randomDir(seed) * radius;
        float3 randomPixel = gm_BaseTextureObject.Sample(gm_BaseTexture, uv + dir).xyz;
        float3 delta = randomPixel - pixel;
        float weight = exp(-dot(delta, delta) / diff);
        result += randomPixel * weight;
        totalWeight += weight;
    }

    result = result / totalWeight;    
    output.color = float4(result, 1.0);  
}