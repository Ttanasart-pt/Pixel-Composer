cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    float2 uWarp;
    
    float uHardScan;
    float uHardPix;
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

// sRGB to Linear.
float ToLinear1(float c) { return (c <= 0.04045) ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4); }
float3 ToLinear(float3 c) { return float3(ToLinear1(c.r), ToLinear1(c.g), ToLinear1(c.b)); }

// Linear to sRGB.
float ToSrgb1(float c) { return (c < 0.0031308) ? c * 12.92 : 1.055 * pow(c, 0.41666) - 0.055; }
float3 ToSrgb(float3 c) { return float3(ToSrgb1(c.r), ToSrgb1(c.g), ToSrgb1(c.b)); }

// Nearest emulated sample given floating point position and texel offset.
float3 Fetch(float2 pos, float2 off) {
    pos = floor(pos * uResolution / 6.0 + off) / (uResolution / 6.0);
    if (max(abs(pos.x - 0.5), abs(pos.y - 0.5)) > 0.5) return float3(0.0, 0.0, 0.0);
    
    return ToLinear(gm_BaseTextureObject.Sample(gm_BaseTexture, pos.xy).rgb);
}

// Distance in emulated pixels to nearest texel.
float2 Dist(float2 pos) { pos = pos * uResolution / 6.0; return -((pos - floor(pos)) - float2(.5, .5)); }

// 1D Gaussian.
float Gaus(float pos, float scale) { return exp2(scale * pos * pos); }

// 3-tap Gaussian filter along horz line.
float3 Horz3(float2 pos, float off) {
    float3 b = Fetch(pos, float2(-1.0, off));
    float3 c = Fetch(pos, float2(0.0, off));
    float3 d = Fetch(pos, float2(1.0, off));
    float dst = Dist(pos).x;
    float scale = uHardPix;
    float wb = Gaus(dst - 1.0, scale);
    float wc = Gaus(dst + 0.0, scale);
    float wd = Gaus(dst + 1.0, scale);
    return (b * wb + c * wc + d * wd) / (wb + wc + wd);
}

// 5-tap Gaussian filter along horz line.
float3 Horz5(float2 pos, float off) {
    float3 a = Fetch(pos, float2(-2.0, off));
    float3 b = Fetch(pos, float2(-1.0, off));
    float3 c = Fetch(pos, float2(0.0, off));
    float3 d = Fetch(pos, float2(1.0, off));
    float3 e = Fetch(pos, float2(2.0, off));
    float dst = Dist(pos).x;
    float scale = uHardPix;
    float wa = Gaus(dst - 2.0, scale);
    float wb = Gaus(dst - 1.0, scale);
    float wc = Gaus(dst + 0.0, scale);
    float wd = Gaus(dst + 1.0, scale);
    float we = Gaus(dst + 2.0, scale);
    return (a * wa + b * wb + c * wc + d * wd + e * we) / (wa + wb + wc + wd + we);
}

// Return scanline weight.
float Scan(float2 pos, float off) {
    float dst = Dist(pos).y;
    return Gaus(dst + off, uHardScan);
}

// Allow nearest three lines to effect pixel.
float3 Tri(float2 pos) {
    float3 a = Horz3(pos, -1.0);
    float3 b = Horz5(pos, 0.0);
    float3 c = Horz3(pos, 1.0);
    float wa = Scan(pos, -1.0);
    float wb = Scan(pos, 0.0);
    float wc = Scan(pos, 1.0);
    return a * wa + b * wb + c * wc;
}

// Distortion of scanlines, and end of screen alpha.
float2 Warp(float2 pos) {
    pos = pos * 2.0 - 1.0;
    pos *= float2(1.0 + (pos.y * pos.y) * uWarp.x, 1.0 + (pos.x * pos.x) * uWarp.y);
    return pos * 0.5 + 0.5;
}

void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    float4 fragColor;
    
    float2 pos = Warp(_input.uv + float2(-0.333, 0.0) / uResolution);
    fragColor.rgb = Tri(pos);
    
    fragColor.a = 1.0;
    fragColor.rgb = ToSrgb(fragColor.rgb);

    output.color = fragColor;
}