/// @enum Enum of shader uniform types. Used in global shader uniforms.
/// @private
enum __BBMOD_EShaderUniformType
{
	Float,
	Float2,
	Float3,
	Float4,
	FloatArray,
	Int,
	Int2,
	Int3,
	Int4,
	IntArray,
	Matrix,
	MatrixArray,
	Sampler,
};

/// @func __bbmod_shader_get_map()
///
/// @desc Retrieves a map of registered shader.
///
/// @return {Id.DsMap<String, Struct.BBMOD_Shader>} The map of registered
/// shader.
///
/// @private
function __bbmod_shader_get_map()
{
	static _map = ds_map_create();
	return _map;
}

/// @func bbmod_shader_register(_name, _shader)
///
/// @desc Registers a shader.
///
/// @param {String} _name The name of the shader.
/// @param {Struct.BBMOD_Shader} _shader The shader.
function bbmod_shader_register(_name, _shader)
{
	gml_pragma("forceinline");
	static _map =__bbmod_shader_get_map();
	_map[? _name] = _shader;
	_shader.__name = _name;
}

/// @func bbmod_shader_exists(shader)
///
/// @desc Checks if there is a shader registered under the name.
///
/// @param {String} _name The name of the shader.
///
/// @return {Bool} Returns `true` if there is a shader registered under the
/// name.
function bbmod_shader_exists(_name)
{
	gml_pragma("forceinline");
	static _map =__bbmod_shader_get_map();
	return ds_map_exists(_map, _name);
}

/// @func bbmod_shader_get(_name)
///
/// @desc Retrieves a shader registered under the name.
///
/// @param {String} _name The name of the shader.
///
/// @return {Struct.BBMOD_Shader} The shader or `undefined` if no
/// shader registered under the given name exists.
function bbmod_shader_get(_name)
{
	gml_pragma("forceinline");
	static _map =__bbmod_shader_get_map();
	return _map[? _name];
}

/// @var {Struct.BBMOD_Shader}
/// @private
global.__bbmodShaderCurrent = undefined;

/// @macro {Struct.BBMOD_Shader} The current shader in use or
/// `undefined`.
/// @readonly
#macro BBMOD_SHADER_CURRENT global.__bbmodShaderCurrent

/// @func BBMOD_Shader([_shader[, _vertexFormat]])
///
/// @extends BBMOD_Class
///
/// @desc Base class for wrappers of raw GameMaker shader assets.
///
/// @param {Asset.GMShader} [_shader] The raw GameMaker shader asset.
/// @param {Struct.BBMOD_VertexFormat} [_vertexFormat] The vertex format required
/// by the shader.
///
/// @note You can use method {@link BBMOD_Shader.add_variant} to add different
/// variants of the shader to be used with different vertex formats.
///
/// @see BBMOD_VertexFormat
function BBMOD_Shader(_shader=undefined, _vertexFormat=undefined)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {String} The name under which is the shader registered or
	/// `undefined`.
	/// @private
	__name = undefined;

	/// @var {Struct} A mapping from vertex format hashes to raw GameMaker shader
	/// assets.
	/// @private
	__raw = {};

	/// @var {Asset.GMShader} The shader asset.
	/// @readonly
	/// @obsolete This has been replaced with {@link BBMOD_Shader.get_variant} and
	/// will always equal `undefined`!
	Raw = undefined;

	/// @var {Struct.BBMOD_VertexFormat} The vertex format required by the
	/// shader.
	/// @readonly
	/// @obsolete This has been replaced with {@link BBMOD_Shader.has_variant}
	/// and will always equal `undefined`!
	VertexFormat = undefined;

	if (_shader != undefined && _vertexFormat != undefined)
	{
		add_variant(_shader, _vertexFormat);
	}

	/// @func add_variant(_shader, _vertexFormat)
	///
	/// @desc Adds a shader variant to be used with a specific vertex format.
	///
	/// @param {Asset.GMShader} [_shader] The raw GameMaker shader asset.
	/// @param {Struct.BBMOD_VertexFormat} [_vertexFormat] The vertex format required
	/// by the shader.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static add_variant = function (_shader, _vertexFormat) {
		gml_pragma("forceinline");
		__raw[$ _vertexFormat.get_hash()] = _shader;
		return self;
	};

	/// @func get_variant(_vertexFormat)
	///
	/// @desc Retrieves a shader variant for given vertex format.
	///
	/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format.
	///
	/// @return {Asset.GMShader} The raw shader asset or `undefined` if the
	/// vertex format is not supported.
	static get_variant = function (_vertexFormat) {
		gml_pragma("forceinline");
		return __raw[$ _vertexFormat.get_hash()];
	};

	/// @func has_variant(_vertexFormat)
	///
	/// @desc Checks whether the shader has a variant for given vertex format.
	///
	/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format.
	///
	/// @return {Bool} Returns `true` if the shader has a variant for given
	/// vertex format.
	static has_variant = function (_vertexFormat) {
		gml_pragma("forceinline");
		return (get_raw(_vertexFormat) != undefined);
	};

	/// @func get_name()
	///
	/// @desc Retrieves the name of the shader.
	///
	/// @return {String} The name of the shader.
	///
	/// @obsolete This method is now obsolete and will always return `undefined`!
	/// Please use `shader_get_name(shader.get_variant(vertexFormat))` instead.
	static get_name = function () {
		gml_pragma("forceinline");
		return undefined;
	};

	/// @func is_compiled()
	///
	/// @desc Checks whether all shader variants are compiled.
	///
	/// @return {Bool} Returns `true` if all shader variants are compiled.
	static is_compiled = function () {
		gml_pragma("forceinline");
		var _keys = variable_struct_get_names(__raw);
		var i = 0;
		repeat (array_length(_keys))
		{
			if (!shader_is_compiled(__raw[$ _keys[i++]]))
			{
				return false;
			}
		}
		return true;
	};

	/// @func get_uniform(_name, _vertexFormat)
	///
	/// @desc Retrieves a handle of a shader uniform.
	///
	/// @param {String} _name The name of the shader uniform.
	///
	/// @return {Id.Uniform} The handle of the shader uniform.
	///
	/// @obsolete This method is now obsolete and will always return -1!
	static get_uniform = function (_name) {
		gml_pragma("forceinline");
		return -1;
	};

	/// @func get_sampler_index(_name)
	///
	/// @desc Retrieves an index of a texture sampler.
	///
	/// @param {String} _name The name of the sampler.
	///
	/// @return {Real} The index of the texture sampler.
	///
	/// @obsolete This method is now obsolete and will always return -1!
	static get_sampler_index = function (_name) {
		gml_pragma("forceinline");
		return -1;
	};

	/// @func on_set()
	///
	/// @desc A function executed when the shader is set.
	static on_set = function () {
	};

	/// @func set(_vertexFormat)
	///
	/// @desc Sets the shader as the current shader.
	///
	/// @param {Struct.BBMOD_VertexFormat} _vertexFormat Used to set a specific
	/// shader variant.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If the shader is not applied.
	static set = function (_vertexFormat) {
		gml_pragma("forceinline");

		if (BBMOD_SHADER_CURRENT != undefined
			&& BBMOD_SHADER_CURRENT != self)
		{
			throw new BBMOD_Exception("Another shader is already active!");
		}

		var _shaderRaw = get_variant(_vertexFormat);

		if (_shaderRaw == undefined)
		{
			throw new BBMOD_Exception(
				"Shader variant for vertex format "
				+ string(_vertexFormat.get_hash())
				+ " was not found!");
		}

		if (BBMOD_SHADER_CURRENT != undefined) // Same as == self
		{
			reset();
		}

		shader_set(_shaderRaw);
		BBMOD_SHADER_CURRENT = self;
		on_set();
		__bbmod_shader_set_globals(_shaderRaw);

		return self;
	};

	/// @func set_material(_material)
	///
	/// @desc Sets shader uniforms using values from the material.
	///
	/// @param {Struct.BBMOD_BaseMaterial} _material The material to take the
	/// values from.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_BaseMaterial
	static set_material = function (_material) {
		return self;
	};

	/// @func is_current()
	///
	/// @desc Checks if the shader is currently in use.
	///
	/// @return {Bool} Returns `true` if the shader is currently in use.
	///
	/// @see BBMOD_Shader.set
	static is_current = function () {
		gml_pragma("forceinline");
		return (BBMOD_SHADER_CURRENT == self);
	};

	/// @func on_reset()
	///
	/// @desc A function executed when the shader is reset.
	static on_reset = function () {
	};

	/// @func reset()
	///
	/// @desc Unsets the shaders.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If the shader is not currently in use.
	static reset = function () {
		gml_pragma("forceinline");
		if (!is_current())
		{
			throw new BBMOD_Exception("Cannot reset a shader which is not active!");
		}
		shader_reset();
		BBMOD_SHADER_CURRENT = undefined;
		on_reset();
		return self;
	};
}

/// @func __bbmod_shader_get_globals()
///
/// @desc
///
/// @return {Array}
///
/// @private
function __bbmod_shader_get_globals()
{
	static _globals = [];
	return _globals;
}

/// @func __bbmod_shader_set_globals(_shader)
///
/// @desc
///
/// @param {Asset.GMShader} _shader
///
/// @private
function __bbmod_shader_set_globals(_shader)
{
	static _globals = __bbmod_shader_get_globals();
	var i = 0;
	repeat (array_length(_globals) / 3)
	{
		var _value = _globals[i + 2];
		if (_value != undefined)
		{
			switch (_globals[i + 1])
			{
			case __BBMOD_EShaderUniformType.Float:
				shader_set_uniform_f(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case __BBMOD_EShaderUniformType.Float2:
				shader_set_uniform_f(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1]);
				break;

			case __BBMOD_EShaderUniformType.Float3:
				shader_set_uniform_f(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1], _value[2]);
				break;

			case __BBMOD_EShaderUniformType.Float4:
				shader_set_uniform_f(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1], _value[2], _value[3]);
				break;

			case __BBMOD_EShaderUniformType.FloatArray:
				shader_set_uniform_f_array(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case __BBMOD_EShaderUniformType.Int:
				shader_set_uniform_i(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case __BBMOD_EShaderUniformType.Int2:
				shader_set_uniform_i(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1]);
				break;

			case __BBMOD_EShaderUniformType.Int3:
				shader_set_uniform_i(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1], _value[2]);
				break;

			case __BBMOD_EShaderUniformType.Int4:
				shader_set_uniform_i(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1], _value[2], _value[3]);
				break;

			case __BBMOD_EShaderUniformType.IntArray:
				shader_set_uniform_i_array(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case __BBMOD_EShaderUniformType.Matrix:
				shader_set_uniform_matrix(shader_get_uniform(_shader, _globals[i]));
				break;

			case __BBMOD_EShaderUniformType.MatrixArray:
				shader_set_uniform_matrix_array(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case __BBMOD_EShaderUniformType.Sampler:
				var _index = shader_get_sampler_index(_shader, _globals[i]);

				if (_index != -1)
				{
					texture_set_stage(_index, _value.__texture);

					var _temp = _value.__filter;
					if (_temp != undefined)
					{
						gpu_set_tex_filter_ext(_index, _temp);
					}

					_temp = _value.__maxAniso;
					if (_temp != undefined)
					{
						gpu_set_tex_max_aniso_ext(_index, _temp);
					}

					_temp = _value.__maxMip;
					if (_temp != undefined)
					{
						gpu_set_tex_max_mip_ext(_index, _temp);
					}

					_temp = _value.__minMip;
					if (_temp != undefined)
					{
						gpu_set_tex_min_mip_ext(_index, _temp);
					}

					_temp = _value.__mipBias;
					if (_temp != undefined)
					{
						gpu_set_tex_mip_bias_ext(_index, _temp);
					}

					_temp = _value.__mipEnable;
					if (_temp != undefined)
					{
						gpu_set_tex_mip_enable_ext(_index, _temp);
					}

					_temp = _value.__mipFilter;
					if (_temp != undefined)
					{
						gpu_set_tex_mip_filter_ext(_index, _temp);
					}

					_temp = _value.__repeat;
					if (_temp != undefined)
					{
						gpu_set_tex_repeat_ext(_index, _temp);
					}
				}
				break;
			}
		}

		i += 3;
	}
}

/// @func bbmod_shader_clear_globals()
///
/// @desc Clears all global uniforms.
function bbmod_shader_clear_globals()
{
	gml_pragma("forceinline");
	static _globals = __bbmod_shader_get_globals();
	array_delete(_globals, 0, array_length(_globals));
}

/// @func bbmod_shader_get_global(_name)
///
/// @desc Retrieves the value of a global shader uniform.
///
/// @param {String} _name The name of the uniform.
///
/// @return {Any} The value of the uniform or `undefined` if it is not set.
/// The type of the returned value changes based on the type of the uniform.
function bbmod_shader_get_global(_name)
{
	gml_pragma("forceinline");
	static _globals = __bbmod_shader_get_globals();
	var i = 0;
	repeat (array_length(_globals) / 3)
	{
		if (_globals[i] == _name)
		{
			return _globals[i + 2];
		}
		i += 3;
	}
	return undefined;
}

/// @func __bbmod_shader_set_global_impl(_name, _type, _value)
///
/// @desc
///
/// @param {String} _name
/// @param {Real} _type
/// @param {Any} _value
///
/// @private
function __bbmod_shader_set_global_impl(_name, _type, _value)
{
	gml_pragma("forceinline");
	static _globals = __bbmod_shader_get_globals();
	var i = 0;
	repeat (array_length(_globals) / 3)
	{
		if (_globals[i] == _name)
		{
			_globals[@ i + 1] = _type;
			_globals[@ i + 2] = _value;
			return;
		}
		i += 3;
	}
	array_push(_globals, _name, _type, _value);
}

/// @func bbmod_shader_set_global_f(_name, _value)
///
/// @desc Sets a value of a global shader uniform of type float.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _value The new value of the uniform.
function bbmod_shader_set_global_f(_name, _value)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.Float, _value);
}

/// @func bbmod_shader_set_global_f2(_name, _v1, _v2)
///
/// @desc Sets a value of a global shader uniform of type float2.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _v1 The first component of the new value.
/// @param {Real} _v2 The second component of the new value.
function bbmod_shader_set_global_f2(_name, _v1, _v2)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.Float2, [_v1, _v2]);
}

/// @func bbmod_shader_set_global_f3(_name, _v1, _v2, _v3)
///
/// @desc Sets a value of a global shader uniform of type float3.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _v1 The first component of the new value.
/// @param {Real} _v2 The second component of the new value.
/// @param {Real} _v3 The third component of the new value.
function bbmod_shader_set_global_f3(_name, _v1, _v2, _v3)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.Float3, [_v1, _v2, _v3]);
}

/// @func bbmod_shader_set_global_f4(_name, _v1, _v2, _v3)
///
/// @desc Sets a value of a global shader uniform of type float4.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _v1 The first component of the new value.
/// @param {Real} _v2 The second component of the new value.
/// @param {Real} _v3 The third component of the new value.
/// @param {Real} _v4 The fourth component of the new value.
function bbmod_shader_set_global_f4(_name, _v1, _v2, _v3, _v4)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.Float4, [_v1, _v2, _v3, _v4]);
}

/// @func bbmod_shader_set_global_f_array(_name, _fArray)
///
/// @desc Sets a value of a global shader uniform of type float array.
///
/// @param {String} _name The name of the uniform.
/// @param {Array<Real>} _fArray The new array of values.
function bbmod_shader_set_global_f_array(_name, _fArray)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.FloatArray, _fArray);
}

/// @func bbmod_shader_set_global_i(_name, _value)
///
/// @desc Sets a value of a global shader uniform of type int.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _value The new value of the uniform.
function bbmod_shader_set_global_i(_name, _value)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.Int, _value);
}

/// @func bbmod_shader_set_global_i2(_name, _v1, _v2)
///
/// @desc Sets a value of a global shader uniform of type int2.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _v1 The first component of the new value.
/// @param {Real} _v2 The second component of the new value.
function bbmod_shader_set_global_i2(_name, _v1, _v2)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.Int2, [_v1, _v2]);
}

/// @func bbmod_shader_set_global_i3(_name, _v1, _v2, _v3)
///
/// @desc Sets a value of a global shader uniform of type int3.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _v1 The first component of the new value.
/// @param {Real} _v2 The second component of the new value.
/// @param {Real} _v3 The third component of the new value.
function bbmod_shader_set_global_i3(_name, _v1, _v2, _v3)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.Int3, [_v1, _v2, _v3]);
}

/// @func bbmod_shader_set_global_i4(_name, _v1, _v2, _v3)
///
/// @desc Sets a value of a global shader uniform of type int4.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _v1 The first component of the new value.
/// @param {Real} _v2 The second component of the new value.
/// @param {Real} _v3 The third component of the new value.
/// @param {Real} _v4 The fourth component of the new value.
function bbmod_shader_set_global_i4(_name, _v1, _v2, _v3, _v4)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.Int4, [_v1, _v2, _v3, _v4]);
}

/// @func bbmod_shader_set_global_i_array(_name, _iArray)
///
/// @desc Sets a value of a global shader uniform of type int array.
///
/// @param {String} _name The name of the uniform.
/// @param {Array<Real>} _iArray The new array of values.
function bbmod_shader_set_global_i_array(_name, _iArray)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.IntArray, _iArray);
}

/// @func bbmod_shader_set_global_matrix(_name)
///
/// @desc Enables passing of the current transform matrix to a global shader uniform.
///
/// @param {String} _name The name of the uniform.
function bbmod_shader_set_global_matrix(_name)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.Matrix, true);
}

/// @func bbmod_shader_set_global_matrix_array(_name, _matrixArray)
///
/// @desc Sets a value of a global shader uniform of type matrix array.
///
/// @param {String} _name The name of the uniform.
/// @param {Array<Real>} _matrixArray The new array of values.
function bbmod_shader_set_global_matrix_array(_name, _matrixArray)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.MatrixArray, _matrixArray);
}

/// @func bbmod_shader_set_global_sampler(_name, _texture)
///
/// @desc Sets a global shader texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Pointer.Texture} _texture The new texture.
function bbmod_shader_set_global_sampler(_name, _texture)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, __BBMOD_EShaderUniformType.Sampler,
		{
			__texture: _texture,
			__filter: undefined,
			__maxAniso: undefined,
			__maxMip: undefined,
			__minMip: undefined,
			__mipBias: undefined,
			__mipEnable: undefined,
			__mipFilter: undefined,
			__repeat: undefined,
		});
}

/// @func bbmod_shader_set_global_sampler_filter(_name, _filter)
///
/// @desc Enables/disables linear filtering of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Bool} _filter Use `true`/`false` to enable/disable linear texture
/// filtering or `undefined` to unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_filter(_name, _filter)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).__filter = _filter;
}

/// @func bbmod_shader_set_global_sampler_max_aniso(_name, _value)
///
/// @desc Sets maximum anisotropy level of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Real} _value The new maximum anisotropy. Use `undefined` to unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_max_aniso(_name, _value)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).__maxAniso = _value;
}

/// @func bbmod_shader_set_global_sampler_max_mip(_name, _value)
///
/// @desc Sets maximum mipmap level of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Real} _value The new maxmimum mipmap level or `undefined` to unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_max_mip(_name, _value)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).__maxMip = _value;
}

/// @func bbmod_shader_set_global_sampler_min_mip(_name, _value)
///
/// @desc Sets minimum mipmap level of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Real} _value The new minimum mipmap level or `undefined` to unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_min_mip(_name, _value)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).__minMip = _value;
}

/// @func bbmod_shader_set_global_sampler_mip_bias(_name, _value)
///
/// @desc Sets mipmap bias of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Real} _value The new bias or `undefined` to unset.
///
/// @note The sampler must be first set using
///
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_mip_bias(_name, _value)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).__mipBias = _value;
}

/// @func bbmod_shader_set_global_sampler_mip_enable(_name, _enable)
///
/// @desc Enable/disable mipmapping of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Bool} _enable Use `true`/`false` to enable/disable mipmapping or
/// `undefined` to unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_mip_enable(_name, _enable)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).__mipEnable = _enable;
}

/// @func bbmod_shader_set_global_sampler_mip_filter(_name, _filter)
///
/// @desc Sets mipmap filter function of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Constant.MipFilter} _filter The new mipmap filter or `undefined` to
/// unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_mip_filter(_name, _filter)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).__mipFilter = _filter;
}

/// @func bbmod_shader_set_global_sampler_repeat(_name, _enable)
///
/// @desc Enable/disable repeat of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Bool} _enable Use `true`/`false` to enable/disable texture repeat or
/// `undefined` to unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_repeat(_name, _enable)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).__repeat = _enable;
}

/// @func bbmod_shader_unset_global(_name)
///
/// @desc Unsets a value of a global shader uniform.
///
/// @param {String} _name The name of the uniform.
function bbmod_shader_unset_global(_name)
{
	gml_pragma("forceinline");
	static _globals = __bbmod_shader_get_globals();
	var i = 0;
	repeat (array_length(_globals) / 3)
	{
		if (_globals[i] == _name)
		{
			array_delete(_globals, i, 3);
			return;
		}
		i += 3;
	}
}
