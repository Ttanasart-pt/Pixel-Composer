cbuffer Base : register(b4) {
    float2 uResolution;
};

cbuffer Data : register(b10) {
    float uIntensity;
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

float overlay(float s, float d) {
    return (d < 0.5) ? 2.0 * s * d : 1.0 - 2.0 * (1.0 - s) * (1.0 - d);
}

float3 overlay(float3 s, float3 d) {
    float3 c;
    c.x = overlay(s.x, d.x);
    c.y = overlay(s.y, d.y);
    c.z = overlay(s.z, d.z);
    return c;
}

float greyScale(float3 col) {
    return dot(col, float3(0.3, 0.59, 0.11));
}

float3x3 saturationMatrix(float saturation) {
    float3 luminance = float3(0.3086, 0.6094, 0.0820);
    float oneMinusSat = 1.0 - saturation;
    float  _r = luminance.x * oneMinusSat;
    float3 red = float3(_r, _r, _r);
    red.r += saturation;
    
    float _g = luminance.y * oneMinusSat;
    float3 green = float3(_g, _g, _g);
    green.g += saturation;
    
    float _b = luminance.z * oneMinusSat;
    float3 blue = float3(_b, _b, _b);
    blue.b += saturation;
    
    return float3x3(red, green, blue);
}

void levels(inout float3 col, float3 inleft, float3 inright, float3 outleft, float3 outright) {
    col = clamp(col, inleft, inright);
    col = (col - inleft) / (inright - inleft);
    col = outleft + col * (outright - outleft);
}

void brightnessAdjust(inout float3 color, float b) {
    color += b;
}

void contrastAdjust(inout float3 color, float c) {
    float t = 0.5 - c * 0.5; 
    color = color * c + t;
}

void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    VertexShaderOutput input = _input;
    
    float2 uv = input.uv;
    float3 base = gm_BaseTextureObject.Sample(gm_BaseTexture, uv).rgb;
    float3 col = base;
    
    float _gr = greyScale(col);
    float3 grey = float3(_gr, _gr, _gr); 
    col = mul(saturationMatrix(0.7), col); 
    grey = overlay(grey, col);
    col = lerp(grey, col, 0.63); 
    levels(col, float3(0., 0., 0.) / 255., float3(228., 255., 239.) / 255., 
                float3(23., 3., 12.) / 255., float3(255., 255., 255.) / 255.); 
    brightnessAdjust(col, -0.1); 
    contrastAdjust(col, 1.05); 
    float3 tint = float3(255., 248., 242.) / 255.;
    levels(col, float3(0., 0., 0.) / 255., float3(255., 224., 255.) / 255., 
                 float3(9., 20., 18.) / 255., float3(255., 255., 255.) / 255.); 
    col = pow(col, float3(0.91, 0.91, 0.91*0.94)); 
    brightnessAdjust(col, -0.04); 
    contrastAdjust(col, 1.14);   
    col = tint * col;
    
    output.color = float4(lerp(base, col, uIntensity), 1.0);
}