#pragma use(uv)

#region -- uv -- [1770002023.9166503]
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vuv   = texture2D( uvMap, uv ).xy;
             vuv.y = 1.0 - vuv.y;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }
#endregion -- uv --

// Hosek-Wilkie Skylight Model 
// By pajunen 
// https://www.shadertoy.com/view/wslfD7

/*
This source is published under the following 3-clause BSD license.

Copyright (c) 2012 - 2013, Lukas Hosek and Alexander Wilkie
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * None of the names of the contributors may be used to endorse or promote 
      products derived from this software without specific prior written 
      permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// Implementation of 2012 Hosek-Wilkie skylight model
// Ground albedo and turbidity are baked into the lookup tables
#define ALBEDO 1
#define TURBIDITY 3

#define PI 3.1415926535897932384626433832795
#define CIE_X 0
#define CIE_Y 1
#define CIE_Z 2

uniform vec2 dimension;
uniform int  mapping;

uniform vec2      turbidity;
uniform int       turbidityUseSurf;
uniform sampler2D turbiditySurf;
        float     turb;

uniform float albedo;
uniform vec2  sunPosition;

uniform vec2  position;
uniform vec2  scale;

float kHosekCoeffsX[54];
float kHosekCoeffsY[54];
float kHosekCoeffsZ[54];

float kHosekRadX[6];
float kHosekRadY[6];
float kHosekRadZ[6];
    
void init() {
    kHosekCoeffsX[ 0] = -1.171419;
    kHosekCoeffsX[ 1] = -0.242975;
    kHosekCoeffsX[ 2] = -8.991334;
    kHosekCoeffsX[ 3] =  9.571216;
    kHosekCoeffsX[ 4] = -0.027729;
    kHosekCoeffsX[ 5] =  0.668826;
    kHosekCoeffsX[ 6] =  0.076835;
    kHosekCoeffsX[ 7] =  3.785611;
    kHosekCoeffsX[ 8] =  0.634764;
    kHosekCoeffsX[ 9] = -1.228554;
    kHosekCoeffsX[10] = -0.291756;
    kHosekCoeffsX[11] =  2.753986;
    kHosekCoeffsX[12] = -2.491780;
    kHosekCoeffsX[13] = -0.046634;
    kHosekCoeffsX[14] =  0.311830;
    kHosekCoeffsX[15] =  0.075465;
    kHosekCoeffsX[16] =  4.463096;
    kHosekCoeffsX[17] =  0.595507;
    kHosekCoeffsX[18] = -1.093124;
    kHosekCoeffsX[19] = -0.244777;
    kHosekCoeffsX[20] =  0.909741;
    kHosekCoeffsX[21] =  0.544830;
    kHosekCoeffsX[22] = -0.295782;
    kHosekCoeffsX[23] =  2.024167;
    kHosekCoeffsX[24] = -0.000515;
    kHosekCoeffsX[25] = -1.069081;
    kHosekCoeffsX[26] =  0.936956;
    kHosekCoeffsX[27] = -1.056994;
    kHosekCoeffsX[28] =  0.015695;
    kHosekCoeffsX[29] = -0.821749;
    kHosekCoeffsX[30] =  1.870818;
    kHosekCoeffsX[31] =  0.706193;
    kHosekCoeffsX[32] = -1.483928;
    kHosekCoeffsX[33] =  0.597821;
    kHosekCoeffsX[34] =  6.864902;
    kHosekCoeffsX[35] =  0.367333;
    kHosekCoeffsX[36] = -1.054871;
    kHosekCoeffsX[37] = -0.275813;
    kHosekCoeffsX[38] =  2.712807;
    kHosekCoeffsX[39] = -5.950110;
    kHosekCoeffsX[40] = -6.554039;
    kHosekCoeffsX[41] =  2.447523;
    kHosekCoeffsX[42] = -0.189517;
    kHosekCoeffsX[43] = -1.454292;
    kHosekCoeffsX[44] =  0.913174;
    kHosekCoeffsX[45] = -1.100218;
    kHosekCoeffsX[46] = -0.174624;
    kHosekCoeffsX[47] =  1.438505;
    kHosekCoeffsX[48] = 11.154810;
    kHosekCoeffsX[49] = -3.266076;
    kHosekCoeffsX[50] = -0.883736;
    kHosekCoeffsX[51] =  0.197010;
    kHosekCoeffsX[52] =  1.991595;
    kHosekCoeffsX[53] =  0.590782;
    
    kHosekCoeffsY[ 0] = -1.185983;
    kHosekCoeffsY[ 1] = -0.258118;
    kHosekCoeffsY[ 2] = -7.761056;
    kHosekCoeffsY[ 3] =  8.317053;
    kHosekCoeffsY[ 4] = -0.033518;
    kHosekCoeffsY[ 5] =  0.667667;
    kHosekCoeffsY[ 6] =  0.059417;
    kHosekCoeffsY[ 7] =  3.820727;
    kHosekCoeffsY[ 8] =  0.632403;
    kHosekCoeffsY[ 9] = -1.268591;
    kHosekCoeffsY[10] = -0.339807;
    kHosekCoeffsY[11] =  2.348503;
    kHosekCoeffsY[12] = -2.023779;
    kHosekCoeffsY[13] = -0.053685;
    kHosekCoeffsY[14] =  0.108328;
    kHosekCoeffsY[15] =  0.084029;
    kHosekCoeffsY[16] =  3.910254;
    kHosekCoeffsY[17] =  0.557748;
    kHosekCoeffsY[18] = -1.071353;
    kHosekCoeffsY[19] = -0.199246;
    kHosekCoeffsY[20] =  0.787839;
    kHosekCoeffsY[21] =  0.197470;
    kHosekCoeffsY[22] = -0.303306;
    kHosekCoeffsY[23] =  2.335298;
    kHosekCoeffsY[24] = -0.082053;
    kHosekCoeffsY[25] =  0.795445;
    kHosekCoeffsY[26] =  0.997231;
    kHosekCoeffsY[27] = -1.089513;
    kHosekCoeffsY[28] = -0.031044;
    kHosekCoeffsY[29] = -0.599575;
    kHosekCoeffsY[30] =  2.330281;
    kHosekCoeffsY[31] =  0.658194;
    kHosekCoeffsY[32] = -1.821467;
    kHosekCoeffsY[33] =  0.667997;
    kHosekCoeffsY[34] =  5.090195;
    kHosekCoeffsY[35] =  0.312516;
    kHosekCoeffsY[36] = -1.040214;
    kHosekCoeffsY[37] = -0.257093;
    kHosekCoeffsY[38] =  2.660489;
    kHosekCoeffsY[39] = -6.506045;
    kHosekCoeffsY[40] = -7.053586;
    kHosekCoeffsY[41] =  2.763153;
    kHosekCoeffsY[42] = -0.243363;
    kHosekCoeffsY[43] = -0.764818;
    kHosekCoeffsY[44] =  0.945294;
    kHosekCoeffsY[45] = -1.116052;
    kHosekCoeffsY[46] = -0.183199;
    kHosekCoeffsY[47] =  1.457694;
    kHosekCoeffsY[48] = 11.636080;
    kHosekCoeffsY[49] = -3.216426;
    kHosekCoeffsY[50] = -1.045594;
    kHosekCoeffsY[51] =  0.228500;
    kHosekCoeffsY[52] =  1.817407;
    kHosekCoeffsY[53] =  0.581040;
    
    kHosekCoeffsZ[ 0] = -1.354183;
    kHosekCoeffsZ[ 1] = -0.513062;
    kHosekCoeffsZ[ 2] = -42.192680;
    kHosekCoeffsZ[ 3] = 42.717720;
    kHosekCoeffsZ[ 4] = -0.005365;
    kHosekCoeffsZ[ 5] =  0.413674;
    kHosekCoeffsZ[ 6] =  0.012352;
    kHosekCoeffsZ[ 7] =  2.520122;
    kHosekCoeffsZ[ 8] =  0.518727;
    kHosekCoeffsZ[ 9] = -1.741434;
    kHosekCoeffsZ[10] = -0.958976;
    kHosekCoeffsZ[11] = -8.230339;
    kHosekCoeffsZ[12] =  9.296799;
    kHosekCoeffsZ[13] = -0.009600;
    kHosekCoeffsZ[14] =  0.499497;
    kHosekCoeffsZ[15] =  0.029555;
    kHosekCoeffsZ[16] =  0.366710;
    kHosekCoeffsZ[17] =  0.352700;
    kHosekCoeffsZ[18] = -0.691735;
    kHosekCoeffsZ[19] =  0.215489;
    kHosekCoeffsZ[20] = -0.876026;
    kHosekCoeffsZ[21] =  0.233412;
    kHosekCoeffsZ[22] = -0.019096;
    kHosekCoeffsZ[23] =  0.474803;
    kHosekCoeffsZ[24] = -0.113851;
    kHosekCoeffsZ[25] =  6.515360;
    kHosekCoeffsZ[26] =  1.225097;
    kHosekCoeffsZ[27] = -1.293189;
    kHosekCoeffsZ[28] = -0.421870;
    kHosekCoeffsZ[29] =  1.620952;
    kHosekCoeffsZ[30] = -0.785860;
    kHosekCoeffsZ[31] = -0.037694;
    kHosekCoeffsZ[32] =  0.663679;
    kHosekCoeffsZ[33] =  0.336494;
    kHosekCoeffsZ[34] = -0.534102;
    kHosekCoeffsZ[35] =  0.212835;
    kHosekCoeffsZ[36] = -0.973552;
    kHosekCoeffsZ[37] = -0.132549;
    kHosekCoeffsZ[38] =  1.007517;
    kHosekCoeffsZ[39] =  0.259826;
    kHosekCoeffsZ[40] =  0.067622;
    kHosekCoeffsZ[41] =  0.001421;
    kHosekCoeffsZ[42] = -0.069160;
    kHosekCoeffsZ[43] =  3.185897;
    kHosekCoeffsZ[44] =  0.864196;
    kHosekCoeffsZ[45] = -1.094800;
    kHosekCoeffsZ[46] = -0.196206;
    kHosekCoeffsZ[47] =  0.575559;
    kHosekCoeffsZ[48] =  0.290626;
    kHosekCoeffsZ[49] =  0.262575;
    kHosekCoeffsZ[50] =  0.764405;
    kHosekCoeffsZ[51] =  0.134749;
    kHosekCoeffsZ[52] =  2.677126;
    kHosekCoeffsZ[53] =  0.646546;

    kHosekRadX[0] =  1.468395;
    kHosekRadX[1] =  2.211970;
    kHosekRadX[2] = -2.845869;
    kHosekRadX[3] = 20.750270;
    kHosekRadX[4] = 15.248220;
    kHosekRadX[5] = 19.376220;
    
    kHosekRadY[0] =  1.516536;
    kHosekRadY[1] =  2.438729;
    kHosekRadY[2] = -3.624121;
    kHosekRadY[3] = 22.986210;
    kHosekRadY[4] = 15.997820;
    kHosekRadY[5] = 20.700270;
    
    kHosekRadZ[0] =  1.234428;
    kHosekRadZ[1] =  2.289628;
    kHosekRadZ[2] = -3.404699;
    kHosekRadZ[3] = 14.994360;
    kHosekRadZ[4] = 34.683900;
    kHosekRadZ[5] = 30.848420;
}

float sample_coeff(int channel, int albedo, int turbidity, int quintic_coeff, int coeff) {
    // int index = 540 * albedo + 54 * turbidity + 9 * quintic_coeff + coeff;
    int index =  9 * quintic_coeff + coeff;
	if (channel == CIE_X) return kHosekCoeffsX[index];
	if (channel == CIE_Y) return kHosekCoeffsY[index];
    if (channel == CIE_Z) return kHosekCoeffsZ[index];
    return 0.;
}

float sample_radiance(int channel, int albedo, int turbidity, int quintic_coeff) {
    //int index = 60 * albedo + 6 * turbidity + quintic_coeff;
    int index = quintic_coeff;
	if (channel == CIE_X) return kHosekRadX[index];
	if (channel == CIE_Y) return kHosekRadY[index];
	if (channel == CIE_Z) return kHosekRadZ[index];
	return 0.;
}

float eval_quintic_bezier(in float[6] control_points, float t) {
	float t2 = t * t;
	float t3 = t2 * t;
	float t4 = t3 * t;
	float t5 = t4 * t;
	
	float t_inv = 1.0 - t;
	float t_inv2 = t_inv * t_inv;
	float t_inv3 = t_inv2 * t_inv;
	float t_inv4 = t_inv3 * t_inv;
	float t_inv5 = t_inv4 * t_inv;
		
	return (
		control_points[0] *             t_inv5 +
		control_points[1] *  5.0 * t  * t_inv4 +
		control_points[2] * 10.0 * t2 * t_inv3 +
		control_points[3] * 10.0 * t3 * t_inv2 +
		control_points[4] *  5.0 * t4 * t_inv  +
		control_points[5] *        t5
	);
}

float transform_sun_zenith(float sun_zenith) {
	float elevation = PI / 2.0 - sun_zenith;
	return pow(elevation / (PI / 2.0), 0.333333);
}

void get_control_points(int channel, int albedo, int turbidity, int coeff, out float[6] control_points) {
	for (int i = 0; i < 6; ++i) control_points[i] = sample_coeff(channel, albedo, turbidity, i, coeff);
}

void get_control_points_radiance(int channel, int albedo, int turbidity, out float[6] control_points) {
	for (int i = 0; i < 6; ++i) control_points[i] = sample_radiance(channel, albedo, turbidity, i);
}

void get_coeffs(int channel, int albedo, int turbidity, float sun_zenith, out float[9] coeffs) {
	float t = transform_sun_zenith(sun_zenith);
	for (int i = 0; i < 9; ++i) {
		float control_points[6]; 
		get_control_points(channel, albedo, turbidity, i, control_points);
		coeffs[i] = eval_quintic_bezier(control_points, t);
	}
}

vec3 mean_spectral_radiance(int albedo, int turbidity, float sun_zenith) {
	vec3 spectral_radiance;
	for (int i = 0; i < 3; ++i) {
		float control_points[6];
        get_control_points_radiance(i, albedo, turbidity, control_points);
		float t = transform_sun_zenith(sun_zenith);
		spectral_radiance[i] = eval_quintic_bezier(control_points, t);
	}
	return spectral_radiance;
}

float F(float theta, float gamma, in float[9] coeffs) {
	float A = coeffs[0];
	float B = coeffs[1];
	float C = coeffs[2];
	float D = coeffs[3];
	float E = coeffs[4];
	float F = coeffs[5];
	float G = coeffs[6];
	float H = coeffs[8];
	float I = coeffs[7];
	float chi = (1.0 + pow(cos(gamma), 2.0)) / pow(1.0 + H*H - 2.0 * H * cos(gamma), 1.5);
	
	return (
		(1.0 + A * exp(B / (cos(theta) + 0.01))) *
		(C + D * exp(E * gamma) + F * pow(cos(gamma), 2.0) + G * chi + I * sqrt(cos(theta)))
	);
}

vec3 spectral_radiance(float theta, float gamma, int albedo, int turbidity, float sun_zenith) {
	vec3 XYZ;
	for (int i = 0; i < 3; ++i) {
		float coeffs[9];
		get_coeffs(i, albedo, turbidity, sun_zenith, coeffs);
		XYZ[i] = F(theta, gamma, coeffs);
	}
	return XYZ;
}

// Returns angle between two directions defined by zentih and azimuth angles
float angle(float z1, float a1, float z2, float a2) {
	return acos(
		sin(z1) * cos(a1) * sin(z2) * cos(a2) +
		sin(z1) * sin(a1) * sin(z2) * sin(a2) +
		cos(z1) * cos(z2));
}

vec3 sample_sky(float view_zenith, float view_azimuth, float sun_zenith, float sun_azimuth) {
	float gamma = angle(view_zenith, view_azimuth, sun_zenith, sun_azimuth);
	float theta = view_zenith; 
	return spectral_radiance(theta, gamma, int(albedo), int(turb), sun_zenith) * mean_spectral_radiance(int(albedo), int(turb), sun_zenith);
}

// CIE-XYZ to linear RGB
vec3 XYZ_to_RGB(vec3 XYZ) {
	mat3 XYZ_to_linear = mat3(
		 3.24096994, -0.96924364, 0.55630080,
		-1.53738318,  1.8759675, -0.20397696,
		-0.49861076,  0.04155506, 1.05697151
	);
	return XYZ_to_linear * XYZ;
}

// Ad-hoc tonemapping, better approach should be used
vec3 tonemap(vec3 color, float exposure) {
	return vec3(2.0) / (vec3(1.0) + exp(-exposure * color)) - vec3(1.0);
}

void main() {
	turb = turbidity.x;
	if(turbidityUseSurf == 1) {
		vec4 _vMap = texture2D( turbiditySurf, v_vTexcoord );
		turb = mix(turbidity.x, turbidity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    init();
    
    vec2 vtx = getUV(v_vTexcoord);
    vec2 uv  = (vtx - position / dimension) * scale;
    vec2 sun = (sunPosition - position) * scale / dimension;
    
    uv.y  = 1. - uv.y;
    sun.y = 1. - sun.y;
    
	float sun_zenith   = PI - sun.y * PI;
	float sun_azimuth  = PI + 2. * PI * sun.x;

	float view_zenith  = PI - uv.y * PI;
	float view_azimuth = PI + 2. * PI * uv.x;

	vec3 XYZ = sample_sky(view_zenith, view_azimuth, sun_zenith, sun_azimuth);
	vec3 RGB = XYZ_to_RGB(XYZ);
	vec3 col = tonemap(RGB, 0.1);
	
	gl_FragColor = vec4(col, 1.0);
}
