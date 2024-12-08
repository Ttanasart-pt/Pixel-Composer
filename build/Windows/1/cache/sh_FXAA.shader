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
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

//Texel size (1/resolution)
uniform vec2 dimension;
uniform float cornerDis;
uniform float mixAmo;

#define SPAN_MAX   (8.0)			//Maximum texel span
//These are more technnical and probably don't need changing:
#define REDUCE_MIN (1.0 / 128.0)		//Minimum "dir" reciprocal
#define REDUCE_MUL (1.0 / 32.0)		//Luma multiplier for "dir" reciprocal

vec4 textureFXAA(sampler2D tex, vec2 uv) {
	vec2 u_texel = 1. / dimension;
	//Sample center and 4 corners
    vec3 rgbCC = texture2D(tex, uv).rgb;
    vec3 rgb00 = texture2D(tex, uv + vec2( -cornerDis, -cornerDis) * u_texel).rgb;
    vec3 rgb10 = texture2D(tex, uv + vec2( +cornerDis, -cornerDis) * u_texel).rgb;
    vec3 rgb01 = texture2D(tex, uv + vec2( -cornerDis, +cornerDis) * u_texel).rgb;
    vec3 rgb11 = texture2D(tex, uv + vec2( +cornerDis, +cornerDis) * u_texel).rgb;
	
	//Luma coefficients
    const vec3 luma = vec3(0.299, 0.587, 0.114);
	//Get luma from the 5 samples
    float lumaCC = dot(rgbCC, luma);
    float luma00 = dot(rgb00, luma);
    float luma10 = dot(rgb10, luma);
    float luma01 = dot(rgb01, luma);
    float luma11 = dot(rgb11, luma);
	
	//Compute gradient from luma values
    vec2 dir = vec2((luma01 + luma11) - (luma00 + luma10), (luma00 + luma01) - (luma10 + luma11));
    
	//Diminish dir length based on total luma
    float dirReduce = max((luma00 + luma10 + luma01 + luma11) * REDUCE_MUL, REDUCE_MIN);
    
	//Divide dir by the distance to nearest edge plus dirReduce
    float rcpDir = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    
	//Multiply by reciprocal and limit to pixel span
    dir = clamp(dir * rcpDir, -SPAN_MAX, SPAN_MAX) * u_texel.xy;
	
	vec4 O = texture2D(tex, uv);
	
	//Average middle texels along dir line
    vec4 A = 0.5 * (
        texture2D(tex, uv - dir * (1.0 / 6.0)) +
        texture2D(tex, uv + dir * (1.0 / 6.0)));
	
	//Average with outer texels along dir line
    vec4 B = A * 0.5 + 0.25 * (
        texture2D(tex, uv - dir * (0.5)) +
        texture2D(tex, uv + dir * (0.5)));
		
		
	//Get lowest and highest luma values
    float lumaMin = min(lumaCC, min(min(luma00, luma10), min(luma01, luma11)));
    float lumaMax = max(lumaCC, max(max(luma00, luma10), max(luma01, luma11)));
    
	//Get average luma
	float lumaB = dot(B.rgb, luma);
	
	//If the average is outside the luma range, using the middle average
    return mix(O, ((lumaB < lumaMin) || (lumaB > lumaMax)) ? A : B, mixAmo);
}

void main() {
	vec4 base = texture2D(   gm_BaseTexture, v_vTexcoord );
	vec4 fxaa = textureFXAA( gm_BaseTexture, v_vTexcoord );
	
    gl_FragData[0] = fxaa;
    gl_FragData[1] = vec4(abs(base.rgb - fxaa.rgb), 1.);
}

