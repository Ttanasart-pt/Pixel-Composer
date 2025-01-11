cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    float uTime;
    float uHDR;
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

#define BG_SPEED float2(-0.03, 0.05)
#define FG_SPEED float2(0.0, -0.02)

float3 make_hdr(float3 col) {
    col = pow(col, float3(uHDR, uHDR, uHDR));
    return col;
}

void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    VertexShaderOutput input = _input;
    
    float2 uv = input.uv;
    
    float2 uv_bg = uv + uTime * BG_SPEED;
    float2 uv_fg = (1.0 - uv) + uTime * FG_SPEED;
    
    float3 bg = gm_BaseTextureObject.Sample(gm_BaseTexture, uv_bg).rgb;
    float3 fg = gm_BaseTextureObject.Sample(gm_BaseTexture, uv_fg).rgb;
    
    float3 col = bg + fg;
    col = col * col;
    col = make_hdr(col);
    
    output.color = float4(col, 1.0);
}