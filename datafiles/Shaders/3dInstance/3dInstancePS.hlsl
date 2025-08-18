#include "CommonPS.hlsl"

struct VS_out {
	float4 Position       : SV_POSITION;
	float4 WorldPosition  : TEXCOORD1;
	float3 ViewPosition   : TEXCOORD2;

	float3 Normal         : NORMAL0;
	float3 ViewNormal     : TEXCOORD4;

	float4 Color          : COLOR0;
	float2 TexCoord       : TEXCOORD0;

	float  cameraDistance : TEXCOORD3;
	uint   InstanceID     : SV_InstanceID;
};

struct PS_out {
	float4 Color  : SV_Target0;
	float4 Normal : SV_Target1;
	float4 Depth  : SV_Target2;
};

cbuffer SceneData : register(b10) {
	float3 camera_position;
	int    gamma_correction;
	
	float4 light_ambient;

	int    light_dir_count;
	int    light_pnt_count;
	int    reserve0, reserve1;
	
	float4 light_dir_direction[16];
	float4 light_dir_color[16];
	float4 light_dir_intensities[4];

	float4 light_pnt_position[16];
	float4 light_pnt_color[16];
	float4 light_pnt_intensities[4];
	float4 light_pnt_radiuses[4];
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

	uv_coord = frac(frac(uv_coord * mat_texScale + mat_texShift) + 1.);
	float4 baseColor = gm_BaseTextureObject.Sample(gm_BaseTexture, uv_coord);
	baseColor *= IN.Color;

	float4 final_color   = baseColor;
	float3 viewDirection = normalize(camera_position - IN.WorldPosition.xyz);
	float3 normal        = normalize(IN.Normal);

	float3 light_effect = light_ambient.rgb;

	for (int i = 0; i < light_dir_count; i++) {
		float3 lightVector = normalize(light_dir_direction[i]);
		float3 light_phong = phongLight(baseColor, normal, lightVector, viewDirection, light_dir_color[i].rgb);
		float4 light_dir_intensity = light_dir_intensities[i / 4];
		float  ints = light_dir_intensity[i % 4];
		
		light_effect += light_phong * float3(ints, ints, ints);
	}

	float light_attenuation = 1.0;

	for (int i = 0; i < light_pnt_count; i++) {
		float3 lightVector = light_pnt_position[i] - IN.WorldPosition.xyz;
		float  light_distance = length(lightVector);
		float4 light_pnt_radius = light_pnt_radiuses[i / 4];
		float  light_rad = light_pnt_radius[i % 4];
		if (light_distance > light_rad) continue;

		lightVector = normalize(lightVector);
		light_attenuation = 1. - pow(light_distance / light_rad, 2.0);

		float3 light_phong = phongLight(baseColor, normal, lightVector, viewDirection, light_pnt_color[i].rgb * light_attenuation);
		float4 light_pnt_intensity = light_pnt_intensities[i / 4];
		float  ints = light_pnt_intensity[i % 4];

		light_effect += light_phong * float3(ints, ints, ints);
	}

	light_effect = max(light_effect, 0.0);
	
	if (gamma_correction == 1) {
		light_effect.r = pow(light_effect.r, 1.0 / 2.2);
		light_effect.g = pow(light_effect.g, 1.0 / 2.2);
		light_effect.b = pow(light_effect.b, 1.0 / 2.2);
	}

	final_color.rgb *= light_effect;
	if (final_color.a < 0.01) discard;

	OUT.Color  = final_color;
	OUT.Normal = float4(.5 + normal * .5, final_color.a);

	float d = 1. - abs(IN.cameraDistance);
	OUT.Depth  = float4(d, d, d, final_color.a);
}
