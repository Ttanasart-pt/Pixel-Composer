//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
// Atmospheric Scattering
// Author: cubi
// https://www.shadertoy.com/view/XlBfRD
// License (MIT) Copyright (C) 2017-2018 Rui. All rights reserved.

#define PI 3.1415926535
#define PI_2 (3.1415926535 * 2.0)

#define EPSILON 1e-5
#define SAMPLES_NUMS 16

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  mapping;

uniform vec2  sunPosition;
uniform float sunRadius;
uniform float sunRadiance;

/*uniform*/ float mieG;
/*uniform*/ float mieHeight;
/*uniform*/ float rayleighHeight;

vec3 waveLambdaMie;
vec3 waveLambdaOzone;
vec3 waveLambdaRayleigh;

float earthRadius;
float earthAtmTopRadius;
vec3  earthCenter;

float saturate(float x) { return clamp(x, 0.0, 1.0); }

vec3 ComputeSphereNormal(vec2 coord, float phiStart, float phiLength, float thetaStart, float thetaLength) {
	vec3 normal;
	normal.x = -sin(thetaStart + coord.y * thetaLength) * sin(phiStart + coord.x * phiLength);
	normal.y = -cos(thetaStart + coord.y * thetaLength);
	normal.z = -sin(thetaStart + coord.y * thetaLength) * cos(phiStart + coord.x * phiLength);
	return normalize(normal);
}

vec2 ComputeRaySphereIntersection(vec3 position, vec3 dir, vec3 center, float radius) {
	vec3 origin = position - center;
	float B = dot(origin, dir);
	float C = dot(origin, origin) - radius * radius;
	float D = B * B - C;

	vec2 minimaxIntersections;
	if (D < 0.0) {
		minimaxIntersections = vec2(-1.0, -1.0);
		
	} else {
		D = sqrt(D);
		minimaxIntersections = vec2(-B - D, -B + D);
	}

	return minimaxIntersections;
}

vec3 ComputeWaveLambdaRayleigh(vec3 lambda) {
	float n   = 1.0003;
	float N   = 2.545E25;
	float pn  = 0.035;
	float n2  = n * n;
	float pi3 = PI * PI * PI;
	float rayleighConst = (8.0 * pi3 * pow(n2 - 1.0, 2.0)) / (3.0 * N) * ((6.0 + 3.0 * pn) / (6.0 - 7.0 * pn));
	
	return rayleighConst / (lambda * lambda * lambda * lambda);
}

float ComputePhaseMie(float theta, float g) {
	float g2 = g * g;
	return (1.0 - g2) / pow(1.0 + g2 - 2.0 * g * saturate(theta), 1.5) / (4.0 * PI);
}

float ComputePhaseRayleigh(float theta) {
	float theta2 = theta * theta;
	return (theta2 * 0.75 + 0.75) / (4.0 * PI);
}

float ChapmanApproximation(float X, float h, float cosZenith) {
	float c = sqrt(X + h);
	float c_exp_h = c * exp(-h);

	if (cosZenith >= 0.0) {
		return c_exp_h / (c * cosZenith + 1.0);
		
	} else {
		float x0 = sqrt(1.0 - cosZenith * cosZenith) * (X + h);
		float c0 = sqrt(x0);

		return 2.0 * c0 * exp(X - x0) - c_exp_h / (1.0 - c * cosZenith);
	}
}

float GetOpticalDepthSchueler(float h, float H, float earthRadius, float cosZenith) {
	return H * ChapmanApproximation(earthRadius / H, h / H, cosZenith);
}

vec3 GetTransmittance(vec3 L, vec3 V) {
	float ch = GetOpticalDepthSchueler(L.y, rayleighHeight, earthRadius, V.y);
	return exp(-(waveLambdaMie + waveLambdaRayleigh) * ch);
}

vec2 ComputeOpticalDepth(vec3 samplePoint, vec3 V, vec3 L, float neg) {
	float rl = length(samplePoint);
	float h  = rl - earthRadius;
	vec3  r  = samplePoint / rl;
    
	float cos_chi_sun = dot(r, L);
	float cos_chi_ray = dot(r, V * neg);

	float opticalDepthSun    = GetOpticalDepthSchueler(h, rayleighHeight, earthRadius, cos_chi_sun);
	float opticalDepthCamera = GetOpticalDepthSchueler(h, rayleighHeight, earthRadius, cos_chi_ray) * neg;

	return vec2(opticalDepthSun, opticalDepthCamera);
}

void AerialPerspective(vec3 start, vec3 end, vec3 V, vec3 L, bool infinite, out vec3 transmittance, out vec3 insctrMie, out vec3 insctrRayleigh) {
	float inf_neg = infinite ? 1.0 : -1.0;

	vec3 sampleStep = (end - start) / float(SAMPLES_NUMS);
	vec3 samplePoint = end - sampleStep;
	vec3 sampleLambda = waveLambdaMie + waveLambdaRayleigh + waveLambdaOzone;

	float sampleLength = length(sampleStep);

	vec3 scattering = vec3(0.0);
	vec2 lastOpticalDepth = ComputeOpticalDepth(end, V, L, inf_neg);

	for (int i = 1; i < SAMPLES_NUMS; i++, samplePoint -= sampleStep) {
		vec2 opticalDepth = ComputeOpticalDepth(samplePoint, V, L, inf_neg);

		vec3 segment_s = exp(-sampleLambda * (opticalDepth.x + lastOpticalDepth.x));
		vec3 segment_t = exp(-sampleLambda * (opticalDepth.y - lastOpticalDepth.y));
		
		transmittance *= segment_t;
		
		scattering = scattering * segment_t;
		scattering += exp(-(length(samplePoint) - earthRadius) / rayleighHeight) * segment_s;

		lastOpticalDepth = opticalDepth;
	}

	insctrMie = scattering * waveLambdaMie * sampleLength;
	insctrRayleigh = scattering * waveLambdaRayleigh * sampleLength;
}

float ComputeSkyboxChapman(vec3 eye, vec3 V, vec3 L, out vec3 transmittance, out vec3 insctrMie, out vec3 insctrRayleigh) {
	bool neg = true;

	vec2 outerIntersections = ComputeRaySphereIntersection(eye, V, earthCenter, earthAtmTopRadius);
	if (outerIntersections.y < 0.0) return 0.0;

	vec2 innerIntersections = ComputeRaySphereIntersection(eye, V, earthCenter, earthRadius);
	if (innerIntersections.x > 0.0) {
		neg = false;
		outerIntersections.y = innerIntersections.x;
	}

	eye -= earthCenter;

	vec3 start = eye + V * max(0.0, outerIntersections.x);
	vec3 end   = eye + V * outerIntersections.y;

	AerialPerspective(start, end, V, L, neg, transmittance, insctrMie, insctrRayleigh);

	bool intersectionTest = innerIntersections.x < 0.0 && innerIntersections.y < 0.0;
	return intersectionTest ? 1.0 : 0.0;
}

vec4 ComputeSkyInscattering(vec3 eye, vec3 V, vec3 L) {
	vec3 insctrMie           = vec3(0.0);
	vec3 insctrRayleigh      = vec3(0.0);
	vec3 insctrOpticalLength = vec3(1.0);
	float intersectionTest   = ComputeSkyboxChapman(eye, V, L, insctrOpticalLength, insctrMie, insctrRayleigh);

	float phaseTheta         = dot(V, L);
	float phaseMie           = ComputePhaseMie(phaseTheta, mieG);
	float phaseRayleigh      = ComputePhaseRayleigh(phaseTheta);
	float phaseNight         = 1.0 - saturate(insctrOpticalLength.x * EPSILON);

	vec3 insctrTotalMie      = insctrMie * phaseMie;
	vec3 insctrTotalRayleigh = insctrRayleigh * phaseRayleigh;
    
	vec3 sky = (insctrTotalMie + insctrTotalRayleigh) * sunRadiance;

	float angle    = saturate((1.0 - phaseTheta) * sunRadius);
	float cosAngle = cos(angle * PI * 0.5);
	float edge     = ((angle >= 0.9) ? smoothstep(0.9, 1.0, angle) : 0.0);
    
	vec3 limbDarkening = GetTransmittance(-L, V);
	limbDarkening     *= pow(vec3(cosAngle), vec3(0.420, 0.503, 0.652)) * mix(vec3(1.0), vec3(1.2,0.9,0.5), edge) * intersectionTest;

	sky += limbDarkening;

	return vec4(sky, phaseNight * intersectionTest);
}

vec3 TonemapACES(vec3 x) {
	float A = 2.51;
	float B = 0.03;
	float C = 2.43;
	float D = 0.59;
	float E = 0.14;
	return (x * (A * x + B)) / (x * (C * x + D) + E);
}

float noise(vec2 uv) {
	return fract(dot(sin(uv.xyx * uv.xyy * 1024.0), vec3(341896.483, 891618.637, 602649.7031)));
}

void main() {
	vec2 uv  = v_vTexcoord;
    vec2 sun = sunPosition / dimension;
    
    uv.y  = 1. - uv.y;
    sun.y = 1. - sun.y;
    
    vec3 V = ComputeSphereNormal(uv, 0.0, PI_2, 0.0, PI);
    vec3 L = ComputeSphereNormal(vec2(sun.x, sun.y), 0.0, PI_2, 0.0, PI);
    
	mieG              = 0.76;
	mieHeight         = 1200.0;
	rayleighHeight    = 8000.0;
	
	earthRadius       = 6360000.0;
	earthAtmTopRadius = 6420000.0;
	earthCenter       = vec3(0, -earthRadius, 0);
	waveLambdaMie     = vec3(2e-7);
    
    // wavelength with 680nm, 550nm, 450nm
    waveLambdaRayleigh = ComputeWaveLambdaRayleigh(vec3(680e-9, 550e-9, 450e-9));
    
    // see https://www.shadertoy.com/view/MllBR2
	waveLambdaOzone = vec3(1.36820899679147, 3.31405330400124, 0.13601728252538) * 0.6e-6 * 2.504;
	
    vec3 eye = vec3(0., 1000.0, 0.);
   	vec4 sky = ComputeSkyInscattering(eye, V, L);
    sky.rgb  = TonemapACES(sky.rgb * 2.0);
    sky.rgb  = pow(sky.rgb, vec3(1.0 / 2.2)); // gamma
    
	gl_FragColor = vec4(sky.rgb, 1.0);
}

