cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    float uRadius;
    float uContrast;
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

void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    VertexShaderOutput input = _input;

    float  r   = 1.0;
    float2 tx  = 1.0 / uResolution;
    float3 acc = float3(0, 0, 0), div = acc;
    float2 vangle = float2(0.0, uRadius / sqrt(float(uIterations)));
    
    float GOLDEN_ANGLE = 2.3999632;
    float2x2 rot = float2x2(cos(GOLDEN_ANGLE), sin(GOLDEN_ANGLE), -sin(GOLDEN_ANGLE), cos(GOLDEN_ANGLE));

    float3 contrast = float3(uContrast, uContrast, uContrast);
    
    for (int j = 0; j < uIterations; j++) {  
        r += 1.0 / r;
        vangle = mul(rot, vangle);

        float2 uv  = input.uv + (r - 1.0) * vangle * tx;
        float3 col = gm_BaseTextureObject.Sample(gm_BaseTexture, uv).xyz;
        float3 bokeh = pow(col, contrast);
        acc += col * bokeh;
        div += bokeh;
    }

    output.color = float4(acc / div, 1.0);
}