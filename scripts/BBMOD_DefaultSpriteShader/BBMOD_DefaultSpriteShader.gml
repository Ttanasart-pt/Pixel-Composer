/// @func BBMOD_DefaultSpriteShader(_shader, _vertexFormat)
///
/// @extends BBMOD_DefaultShader
///
/// @desc A variant of {@link BBMOD_DefaultShader} which can be used when
/// rendering GameMaker sprites.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
///
/// @see BBMOD_DefaultMaterial
function BBMOD_DefaultSpriteShader(_shader, _vertexFormat)
	: BBMOD_DefaultShader(_shader, _vertexFormat) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static DefaultShader_set_material = set_material;

	static set_material = function (_material) {
		gml_pragma("forceinline");
		DefaultShader_set_material(_material);

		var _shaderCurrent = shader_current();

		var _texture = _material.BaseOpacity;
		if (_texture != pointer_null)
		{
			var _uBaseOpacityUV = shader_get_uniform(_shaderCurrent, "bbmod_BaseOpacityUV");
			shader_set_uniform_f_array(_uBaseOpacityUV, texture_get_uvs(_texture));
		}

		_texture = _material.NormalSmoothness ?? _material.NormalRoughness;
		if (_texture != undefined)
		{
			var _uNormalWUV = shader_get_uniform(_shaderCurrent, "bbmod_NormalWUV");
			shader_set_uniform_f_array(_uNormalWUV, texture_get_uvs(_texture));
		}

		_texture = _material.SpecularColor ?? _material.MetallicAO;
		if (_texture != undefined)
		{
			var _uMaterialUV = shader_get_uniform(_shaderCurrent, "bbmod_MaterialUV");
			shader_set_uniform_f_array(_uMaterialUV, texture_get_uvs(_texture));
		}

		return self;
	};
}
