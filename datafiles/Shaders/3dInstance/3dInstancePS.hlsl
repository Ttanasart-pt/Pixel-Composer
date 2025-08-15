#include "CommonPS.hlsl"

#define LIGHT_DIR_LIMIT  16
#define LIGHT_PNT_LIMIT  16

struct VS_out {
	float4 Position : SV_POSITION;
	float3 Normal   : NORMAL0;
	float4 Color    : COLOR0;
	float2 TexCoord : TEXCOORD0;
	
	float4 WorldPosition  : TEXCOORD1;
	float3 ViewPosition   : TEXCOORD2;
	float  cameraDistance : TEXCOORD3;
};

struct PS_out {
	float4 Color : SV_Target0;
};

cbuffer SceneData : register(b10) {
	float3 camera_position;
	int    gamma_correction;
	
	float4 light_ambient;

	int    light_dir_count;
	float3 light_dir_direction[LIGHT_DIR_LIMIT];
	float4 light_dir_color[LIGHT_DIR_LIMIT];
	float  light_dir_intensity[LIGHT_DIR_LIMIT];

	int    light_pnt_count;
	float3 light_pnt_position[LIGHT_PNT_LIMIT];
	float4 light_pnt_color[LIGHT_PNT_LIMIT];
	float  light_pnt_intensity[LIGHT_PNT_LIMIT];
	float  light_pnt_radius[LIGHT_PNT_LIMIT];
}

cbuffer MatData : register(b11) {
	float  mat_diffuse;
	float  mat_specular;
	float  mat_shine;
	int    mat_metalic;
	float  mat_reflective;
	float2 mat_texScale;
	float2 mat_texShift;

	int    mat_flip;
};

float3 phongLight(float4 baseColor, float3 normal, float3 lightVec, float3 viewVec, float3 lightColor) {
	float3 lightDir = normalize(lightVec);
	float3 viewDir  = normalize(viewVec);
	float3 refcDir  = reflect(-lightDir, normal);

	float kD = 1.0, kS = 0.0;

	if (mat_diffuse + mat_specular != 0.0) {
		kD = mat_diffuse / (mat_diffuse + mat_specular);
		kS = mat_specular / (mat_diffuse + mat_specular);
	}
	
	float  sLambert  = max(0.0, dot(normal, lightDir));
	float3 lLambert  = float3(sLambert,sLambert,sLambert) * lightColor;

	float  specular  = pow(max(dot(viewDir, refcDir), 0.0), max(0.001, mat_shine));
	float3 lSpecular = float3(specular,specular,specular) * lightColor;
	if (mat_metalic == 1) lSpecular *= baseColor.rgb;

	return kD * lLambert + kS * lSpecular;
}

void main(in VS_out IN, out PS_out OUT) {
	float2 uv_coord = IN.TexCoord;
	if (mat_flip == 1) uv_coord.y = -uv_coord.y;

	uv_coord = frac(uv_coord * mat_texScale + mat_texShift);
	float4 baseColor = gm_BaseTextureObject.Sample(gm_BaseTexture, uv_coord);
	baseColor *= IN.Color;

	float4 final_color   = baseColor;
	float3 viewDirection = normalize(camera_position - IN.WorldPosition.xyz);

	float3 light_effect = light_ambient.rgb;

	for (int i = 0; i < light_dir_count; i++) {
		float3 lightVector = normalize(light_dir_direction[i]);
		float3 light_phong = phongLight(baseColor, IN.Normal, lightVector, viewDirection, light_dir_color[i].rgb);
		float  ints = light_dir_intensity[i];

		// light_effect += light_phong * float3(ints, ints, ints);
		light_effect += float3(ints, ints, ints);
	}

	for (int i = 0; i < light_pnt_count; i++) {
		float3 lightVector = light_pnt_position[i] - IN.WorldPosition.xyz;
		float light_distance = length(lightVector);
		if (light_distance > light_pnt_radius[i]) continue;

		lightVector = normalize(lightVector);
		float3 light_phong = phongLight(baseColor, IN.Normal, lightVector, viewDirection, light_pnt_color[i].rgb * (1.0 - pow(light_distance / light_pnt_radius[i], 2.0)));
		float  ints = light_pnt_intensity[i];

		light_effect += light_phong * float3(ints, ints, ints);
	}

	light_effect.r = max(light_effect.r, 0.0);
	light_effect.g = max(light_effect.g, 0.0);
	light_effect.b = max(light_effect.b, 0.0);
	
	if (gamma_correction == 1) {
		light_effect.r = pow(light_effect.r, 1.0 / 2.2);
		light_effect.g = pow(light_effect.g, 1.0 / 2.2);
		light_effect.b = pow(light_effect.b, 1.0 / 2.2);
	}

	final_color.rgb *= light_effect;
	if (final_color.a < 0.1) discard;

	OUT.Color = final_color;
	OUT.Color.rgb = light_effect;

}
