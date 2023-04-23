// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Defines
//

// Maximum number of bones of animated models
#define BBMOD_MAX_BONES 128
// Maximum number of vec4 uniforms for dynamic batch data
#define BBMOD_MAX_BATCH_VEC4S 192

////////////////////////////////////////////////////////////////////////////////
//
// Attributes
//
attribute vec4 in_Position;

attribute vec3 in_Normal;

attribute vec2 in_TextureCoord0;

attribute vec4 in_TangentW;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//
uniform mat4 bbmod_NormalMatrix;

uniform vec2 bbmod_TextureOffset;
uniform vec2 bbmod_TextureScale;

// 1.0 to enable shadows
uniform float bbmod_ShadowmapEnableVS;
// WORLD_VIEW_PROJECTION matrix used when rendering shadowmap
uniform mat4 bbmod_ShadowmapMatrix;
// Offsets vertex position by its normal scaled by this value
uniform float bbmod_ShadowmapNormalOffset;

////////////////////////////////////////////////////////////////////////////////
//
// Varyings
//
varying vec3 v_vVertex;

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying vec4 v_vPosition;

varying vec4 v_vPosShadowmap;

varying vec2 v_vSplatmapCoord;

varying vec4 v_vEye;

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//

/// @desc Transforms vertex and normal by animation and/or batch data.
///
/// @param vertex Variable to hold the transformed vertex.
/// @param normal Variable to hold the transformed normal.
/// @param tangent Variable to hold the transformed tangent.
/// @param bitangent Variable to hold the transformed bitangent.
void Transform(
	inout vec4 vertex,
	inout vec3 normal,
	inout vec3 tangent,
	inout vec3 bitangent)
{

	vertex = gm_Matrices[MATRIX_WORLD] * vertex;
	normal = normalize((bbmod_NormalMatrix * vec4(normal, 0.0)).xyz);
	tangent = normalize((bbmod_NormalMatrix * vec4(tangent, 0.0)).xyz);
	bitangent = normalize((bbmod_NormalMatrix * vec4(bitangent, 0.0)).xyz);
}

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
	vec4 position = in_Position;
	vec3 normal = in_Normal;
	vec3 tangent = in_TangentW.xyz;
	vec3 bitangent = cross(normal, tangent) * in_TangentW.w;

	Transform(position, normal, tangent, bitangent);

	vec4 positionWVP = gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * position);
	v_vVertex = position.xyz;

	gl_Position = positionWVP;
	v_vPosition = positionWVP;
	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	v_vEye.xyz = normalize(-vec3(
		gm_Matrices[MATRIX_VIEW][0][2],
		gm_Matrices[MATRIX_VIEW][1][2],
		gm_Matrices[MATRIX_VIEW][2][2]
	));
	v_vEye.w = (gm_Matrices[MATRIX_PROJECTION][2][3] == 0.0) ? 1.0 : 0.0;

	v_mTBN = mat3(tangent, bitangent, normal);

	v_vSplatmapCoord = in_TextureCoord0;

	////////////////////////////////////////////////////////////////////////////
	// Vertex position in shadowmap
	if (bbmod_ShadowmapEnableVS == 1.0)
	{
		v_vPosShadowmap = bbmod_ShadowmapMatrix
			* vec4(v_vVertex + normal * bbmod_ShadowmapNormalOffset, 1.0);
	}
}
