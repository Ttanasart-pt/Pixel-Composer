/// @func BBMOD_DefaultLightmapShader(_shader, _vertexFormat)
///
/// @extends BBMOD_DefaultShader
///
/// @desc Shader used by lightmapped materials.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
///
/// @see BBMOD_LightmapMaterial
function BBMOD_DefaultLightmapShader(_shader, _vertexFormat)
	: BBMOD_DefaultShader(_shader, _vertexFormat) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static DefaultShader_on_set = on_set;
	static DefaultShader_set_material = set_material;

	static set_ibl = function (_ibl=undefined) {
		gml_pragma("forceinline");

		static _iblNull = sprite_get_texture(BBMOD_SprBlack, 0);
		var _texture = _iblNull;
		var _texel = 0.0;

		_ibl ??= global.__bbmodImageBasedLight;
		if (_ibl != undefined
			&& _ibl.Enabled
			&& _ibl.AffectLightmaps)
		{
			_texture = _ibl.Texture;
			_texel = _ibl.Texel;
		}

		var _shaderCurrent = shader_current();
		var _uIBL = shader_get_sampler_index(_shaderCurrent, "bbmod_IBL");

		texture_set_stage(_uIBL, _texture);
		gpu_set_tex_mip_enable_ext(_uIBL, mip_off);
		gpu_set_tex_filter_ext(_uIBL, true);
		gpu_set_tex_repeat_ext(_uIBL, false);
		shader_set_uniform_f(
			shader_get_uniform(_shaderCurrent, "bbmod_IBLTexel"),
			_texel, _texel)

		return self;
	};

	static set_ambient_light = function (_up=undefined, _down=undefined) {
		gml_pragma("forceinline");
		var _shaderCurrent = shader_current();
		var _uLightAmbientUp = shader_get_uniform(_shaderCurrent, "bbmod_LightAmbientUp");
		var _uLightAmbientDown = shader_get_uniform(_shaderCurrent, "bbmod_LightAmbientDown");
		if (global.__bbmodAmbientAffectLightmap)
		{
			_up ??= global.__bbmodAmbientLightUp;
			_down ??= global.__bbmodAmbientLightDown;
			shader_set_uniform_f(_uLightAmbientUp,
				_up.Red / 255.0, _up.Green / 255.0, _up.Blue / 255.0, _up.Alpha);
			shader_set_uniform_f(_uLightAmbientDown,
				_down.Red / 255.0, _down.Green / 255.0, _down.Blue / 255.0, _down.Alpha);
		}
		else
		{
			shader_set_uniform_f(_uLightAmbientUp, 0.0, 0.0, 0.0, 0.0);
			shader_set_uniform_f(_uLightAmbientDown, 0.0, 0.0, 0.0, 0.0);
		}
		return self;
	};

	static set_directional_light = function (_light=undefined) {
		gml_pragma("forceinline");
		_light ??= global.__bbmodDirectionalLight;
		var _shaderCurrent = shader_current();
		var _uLightDirectionalDir = shader_get_uniform(_shaderCurrent, "bbmod_LightDirectionalDir");
		var _uLightDirectionalColor = shader_get_uniform(_shaderCurrent, "bbmod_LightDirectionalColor");
		if (_light != undefined
			&& _light.Enabled
			&& _light.AffectLightmaps)
		{
			var _direction = _light.Direction;
			shader_set_uniform_f(_uLightDirectionalDir,
				_direction.X, _direction.Y, _direction.Z);
			var _color = _light.Color;
			shader_set_uniform_f(_uLightDirectionalColor,
				_color.Red / 255.0,
				_color.Green / 255.0,
				_color.Blue / 255.0,
				_color.Alpha);
		}
		else
		{
			shader_set_uniform_f(_uLightDirectionalDir, 0.0, 0.0, -1.0);
			shader_set_uniform_f(_uLightDirectionalColor, 0.0, 0.0, 0.0, 0.0);
		}
		return self;
	};

	static set_punctual_lights = function (_lights=undefined) {
		gml_pragma("forceinline");

		_lights ??= global.__bbmodPunctualLights;

		var _maxLights = MaxPunctualLights;

		var _indexA = 0;
		var _indexMaxA = _maxLights * 8;
		var _dataA = array_create(_indexMaxA, 0.0);

		var _indexB = 0;
		var _indexMaxB = _maxLights * 6;
		var _dataB = array_create(_indexMaxB, 0.0);

		var i = 0;

		repeat (array_length(_lights))
		{
			var _light = _lights[i++];

			if (_light.Enabled
				&& _light.AffectLightmaps)
			{
				_light.Position.ToArray(_dataA, _indexA);
				_dataA[@ _indexA + 3] = _light.Range;
				var _color = _light.Color;
				_dataA[@ _indexA + 4] = _color.Red / 255.0;
				_dataA[@ _indexA + 5] = _color.Green / 255.0;
				_dataA[@ _indexA + 6] = _color.Blue / 255.0;
				_dataA[@ _indexA + 7] = _color.Alpha;
				_indexA += 8;

				if (_light.is_instance(BBMOD_SpotLight)) // Ugh, but works!
				{
					_dataB[@ _indexB] = 1.0; // Is spot light
					_dataB[@ _indexB + 1] = dcos(_light.AngleInner);
					_dataB[@ _indexB + 2] = dcos(_light.AngleOuter);
					_light.Direction.ToArray(_dataB, _indexB + 3);
				}
				_indexB += 6;

				if (_indexA >= _indexMaxA)
				{
					break;
				}
			}
		}

		var _shaderCurrent = shader_current();

		shader_set_uniform_f_array(
			shader_get_uniform(_shaderCurrent, "bbmod_LightPunctualDataA"),
			_dataA);
		shader_set_uniform_f_array(
			shader_get_uniform(_shaderCurrent, "bbmod_LightPunctualDataB"),
			_dataB);

		return self;
	};

	/// @func set_lightmap(_texture)
	///
	/// @desc Sets the `bbmod_Lightmap` uniform.
	///
	/// @param {Pointer.Texture} [_texture] The new RGBM encoded lightmap
	/// texture. If not specified, defaults to the one configured using
	/// {@link bbmod_lightmap_set}.
	///
	/// @return {Struct.BBMOD_DefaultLightmapShader} Returns `self`.
	static set_lightmap = function (_texture=global.__bbmodLightmap) {
		gml_pragma("forceinline");
		var _uLightmap = shader_get_sampler_index(shader_current(), "bbmod_Lightmap");
		texture_set_stage(_uLightmap, _texture);
		gpu_set_tex_mip_enable_ext(_uLightmap, mip_off);
		gpu_set_tex_filter_ext(_uLightmap, true);
		return self;
	};

	static on_set = function () {
		DefaultShader_on_set();
		set_lightmap();
		return self;
	};

	static set_material = function (_material) {
		gml_pragma("forceinline");
		DefaultShader_set_material(_material);
		if (_material.Lightmap != undefined)
		{
			set_lightmap(_material.Lightmap);
		}
		return self;
	};
}

/// @var {Pointer.Texture}
/// @private
global.__bbmodLightmap = sprite_get_texture(BBMOD_SprBlack, 0);

/// @func bbmod_lightmap_get()
///
/// @desc Retrieves the default lightmap texture used by all lightmapped
/// materials.
///
/// @return {Pointer.Texture} The default RGBM encoded lightmap texture.
function bbmod_lightmap_get()
{
	gml_pragma("forceinline");
	return global.__bbmodLightmap;
}

/// @func bbmod_lightmap_set(_texture)
///
/// @desc Changes the default lightmap texture used by all lightmapped
/// materials.
///
/// @param {Pointer.Texture} _texture The new default RGBM encoded lightmap
/// texture.
function bbmod_lightmap_set(_texture)
{
	gml_pragma("forceinline");
	global.__bbmodLightmap = _texture;
}
