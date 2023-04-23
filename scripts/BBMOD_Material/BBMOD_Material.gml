/// @func __bbmod_material_get_map()
///
/// @desc Retrieves a map of registered materials.
///
/// @return {Id.DsMap<String, Struct.BBMOD_Material>} The map of registered
/// materials.
///
/// @private
function __bbmod_material_get_map()
{
	static _map = ds_map_create();
	return _map;
}

/// @func bbmod_material_register(_name, _material)
///
/// @desc Registers a material.
///
/// @param {String} _name The name of the material.
/// @param {Struct.BBMOD_Material} _material The material.
function bbmod_material_register(_name, _material)
{
	gml_pragma("forceinline");
	static _map =__bbmod_material_get_map();
	_map[? _name] = _material;
	_material.__name = _name;
}

/// @func bbmod_material_exists(_name)
///
/// @desc Checks if there is a material registered under the name.
///
/// @param {String} _name The name of the material.
///
/// @return {Bool} Returns `true` if there is a material registered under the
/// name.
function bbmod_material_exists(_name)
{
	gml_pragma("forceinline");
	static _map =__bbmod_material_get_map();
	return ds_map_exists(_map, _name);
}

/// @func bbmod_material_get(_name)
///
/// @desc Retrieves a material registered under the name.
///
/// @param {String} _name The name of the material.
///
/// @return {Struct.BBMOD_Material} The material or `undefined` if no
/// material registered under the given name exists.
function bbmod_material_get(_name)
{
	gml_pragma("forceinline");
	static _map =__bbmod_material_get_map();
	return _map[? _name];
}

/// @var {Struct.BBMOD_Material} The currently applied material or `undefined`.
/// @private
global.__bbmodMaterialCurrent = undefined;

/// @func BBMOD_Material([_shader])
///
/// @extends BBMOD_Resource
///
/// @desc Base class for materials.
///
/// @param {Struct.BBMOD_Shader} [_shader] A shader that the material uses in
/// the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you would
/// like to use {@link BBMOD_Material.set_shader} to specify shaders used in
/// specific render passes.
///
/// @see BBMOD_Shader
function BBMOD_Material(_shader=undefined)
	: BBMOD_Resource() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Resource_destroy = destroy;

	/// @var {String} The name under which is this material registered or
	/// `undefined`.
	/// @private
	__name = undefined;

	/// @var {Real} Render passes in which is the material rendered. Defaults
	/// to 0 (no passes).
	/// @readonly
	/// @see BBMOD_ERenderPass
	RenderPass = 0;

	/// @var {Array<Struct.BBMOD_Shader>} Shaders used in specific render passes.
	/// @private
	/// @see BBMOD_Material.set_shader
	/// @see BBMOD_Material.get_shader
	Shaders = array_create(BBMOD_ERenderPass.SIZE, undefined);

	/// @var {Struct.BBMOD_RenderQueue} The render queue used by this material.
	/// Defaults to the default BBMOD render queue.
	/// @readonly
	/// @see BBMOD_RenderQueue
	/// @see bbmod_render_queue_get_default
	RenderQueue = bbmod_render_queue_get_default();

	/// @var {Function} A function that is executed when the shader is applied.
	/// Must take the material as the first argument. Use `undefined` if you do
	/// not want to execute any function. Defaults to `undefined`.
	OnApply = undefined;

	/// @var {Constant.BlendMode} A blend mode. Default value is `bm_normal`.
	BlendMode = bm_normal;

	/// @var {Constant.CullMode} A culling mode. Default value is
	/// `cull_counterclockwise`.
	Culling = cull_counterclockwise;

	/// @var {Bool} If `true` then models using this material should write to
	/// the depth buffer. Default value is `true`.
	ZWrite = true;

	/// @var {Bool} If `true` then models using this material should be tested
	/// against the depth buffer. Defaults value is `true`.
	ZTest = true;

	/// @var {Constant.CmpFunc} The function used for depth testing when
	/// {@link BBMOD_Material.ZTest} is enabled. Default value is
	/// `cmpfunc_lessequal`.
	ZFunc = cmpfunc_lessequal;

	/// @var {Real} Discard pixels with alpha less than this value. Use values
	/// in range 0..1.
	AlphaTest = 1.0;

	/// @var {Bool} Use `true` to enable alpha blending. This can have negative
	/// effect on performance, therefore it should be used only when necessary.
	/// Default value is `false`.
	AlphaBlend = false;

	/// @var {Real} Use one of the `mip_` constants. Default value is `mip_on`.
	Mipmapping = mip_on;

	/// @var {Real} Defines a bias for which mip level is used. Can be also
	/// negative values to select lower mip levels. E.g. if mip level 2 would be
	/// normally selected and bias was -1, then level 1 would be selected instead
	/// and if it was 1, then level 3 would be selected instead. Default value is
	/// 0.
	MipBias = 0;

	/// @var {Real} The mip filter mode used for the material. Use one of the
	/// `tf_` constants. Default value is `tf_anisotropic`.
	MipFilter = tf_anisotropic;

	/// @var {Real} The minimum mip level used, where 0 is the highest resolution,
	/// 1 is the first mipmap, 2 is the second etc. Default value is 0.
	MipMin = 0;

	/// @var {Real} The maximum mip level used, where 0 is the highest resolution,
	/// 1 is the first mipmap, 2 is the second etc. Default value is 16.
	MipMax = 16;

	/// @var {Real} The maximum level of anisotropy when
	/// {@link BBMOD_Material.MipFilter} is set to `tf_anisotropic`. Must be in
	/// range 1..16. Default value is 16.
	Anisotropy = 16;

	/// @var {Bool} Use `false` to disable linear texture filtering for this
	/// material. Default value is `true`.
	Filtering = true;

	/// @var {Bool} Use `true` to enable texture repeat for this material.
	/// Default value is `false`.
	Repeat = false;

	/// @var {Pointer.Texture} A texture with a base color in the RGB channels
	/// and opacity in the alpha channel.
	BaseOpacity = pointer_null;

	__baseOpacitySprite = undefined;

	/// @func copy(_dest)
	///
	/// @desc Copies properties of this material into another material.
	///
	/// @param {Struct.BBMOD_Material} _dest The destination material.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static copy = function (_dest) {
		_dest.__name = __name;
		_dest.RenderPass = RenderPass;
		_dest.Shaders = array_create(BBMOD_ERenderPass.SIZE, undefined);
		array_copy(_dest.Shaders, 0, Shaders, 0, BBMOD_ERenderPass.SIZE);
		_dest.RenderQueue = RenderQueue;
		_dest.OnApply = OnApply;
		_dest.BlendMode = BlendMode;
		_dest.Culling = Culling;
		_dest.ZWrite = ZWrite;
		_dest.ZTest = ZTest;
		_dest.ZFunc = ZFunc;
		_dest.AlphaTest = AlphaTest;
		_dest.AlphaBlend = AlphaBlend;
		_dest.Mipmapping = Mipmapping;
		_dest.MipBias = MipBias;
		_dest.MipFilter = MipFilter;
		_dest.MipMin = MipMin;
		_dest.MipMax = MipMax;
		_dest.Anisotropy = Anisotropy;
		_dest.Filtering = Filtering;
		_dest.Repeat = Repeat;

		if (_dest.__baseOpacitySprite != undefined)
		{
			sprite_delete(_dest.__baseOpacitySprite);
			_dest.__baseOpacitySprite = undefined;
		}

		if (__baseOpacitySprite != undefined)
		{
			_dest.__baseOpacitySprite = sprite_duplicate(__baseOpacitySprite);
			_dest.BaseOpacity = sprite_get_texture(_dest.__baseOpacitySprite, 0);
		}
		else
		{
			_dest.BaseOpacity = BaseOpacity;
		}

		return self;
	};

	/// @func clone()
	///
	/// @desc Creates a clone of the material.
	///
	/// @return {Struct.BBMOD_Material} The created clone.
	static clone = function () {
		var _clone = new BBMOD_Material();
		copy(_clone);
		return _clone;
	};

	/// @func to_json(_json)
	///
	/// @desc Saves material properties to a JSON object.
	///
	/// @param {Struct} _json The object to save the properties to.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If an error occurs.
	static to_json = function (_json) {
		var _shaders = {};
		var _pass = 0;
		repeat (BBMOD_ERenderPass.SIZE)
		{
			var _shader = Shaders[_pass];
			if (_shader != undefined)
			{
				var _passName = bbmod_render_pass_to_string(_pass);
				if (_shader.__name == undefined)
				{
					throw new BBMOD_Exception(
						"Cannot save to JSON, shader for render pass \""
						+ _passName + "\" is not registered!");
				}
				else
				{
					_shaders[$ _passName] = _shader.__name;
				}
			}
			++_pass;
		}
		_json.Shaders = _shaders;

		if (RenderQueue.Name != undefined)
		{
			_json.RenderQueue = RenderQueue.Name;
		}

		// TODO: Save OnApply

		_json.BlendMode = BlendMode;
		_json.Culling = Culling;
		_json.ZWrite = ZWrite;
		_json.ZTest = ZTest;
		_json.ZFunc = ZFunc;
		_json.AlphaTest = AlphaTest;
		_json.AlphaBlend = AlphaBlend;
		_json.Mipmapping = Mipmapping;
		_json.MipBias = MipBias;
		_json.MipFilter = MipFilter;
		_json.MipMin = MipMin;
		_json.MipMax = MipMax;
		_json.Anisotropy = Anisotropy;
		_json.Filtering = Filtering;
		_json.Repeat = Repeat;

		// TODO: Save BaseOpacity/__baseOpacitySprite

		return self;
	};

	/// @func from_json(_json)
	///
	/// @desc Loads material properties from a JSON object.
	///
	/// @param {Struct} _json The object to load the properties from.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If an error occurs.
	static from_json = function (_json) {
		if (variable_struct_exists(_json, "Shaders"))
		{
			var _shaders = _json.Shaders;
			var _keys = variable_struct_get_names(_shaders);
			var _index = 0;
			repeat (array_length(_keys))
			{
				var _passName = _keys[_index++];
				var _pass = bbmod_render_pass_from_string(_passName);
				var _shader = _shaders[$ _passName];
				if (is_string(_shader))
				{
					_shader = bbmod_shader_get(_shader);
				}
				set_shader(_pass, _shader);
			}
		}

		if (variable_struct_exists(_json, "RenderQueue"))
		{
			var _renderQueue = _json.RenderQueue;
			if (is_string(_renderQueue))
			{
				var _renderQueues = bbmod_render_queues_get();
				var _index = 0;
				repeat (array_length(_renderQueues))
				{
					with (_renderQueues[_index++])
					{
						if (Name == _renderQueue)
						{
							_renderQueue = self;
							break;
						}
					}
				}
				if (is_string(_renderQueue))
				{
					throw new BBMOD_Exception("Invalid render queue \"" + _renderQueue + "\"!");
				}
			}
		}

		if (variable_struct_exists(_json, "OnApply"))
		{
			OnApply = _json.OnApply;
		}

		if (variable_struct_exists(_json, "BlendMode"))
		{
			BlendMode = _json.BlendMode;
		}

		if (variable_struct_exists(_json, "Culling"))
		{
			Culling = _json.Culling;
		}

		if (variable_struct_exists(_json, "ZWrite"))
		{
			ZWrite = _json.ZWrite;
		}

		if (variable_struct_exists(_json, "ZTest"))
		{
			ZTest = _json.ZTest;
		}

		if (variable_struct_exists(_json, "ZFunc"))
		{
			ZFunc = _json.ZFunc;
		}

		if (variable_struct_exists(_json, "AlphaTest"))
		{
			AlphaTest = _json.AlphaTest;
		}

		if (variable_struct_exists(_json, "AlphaBlend"))
		{
			AlphaBlend = _json.AlphaBlend;
		}

		if (variable_struct_exists(_json, "Mipmapping"))
		{
			Mipmapping = _json.Mipmapping;
		}

		if (variable_struct_exists(_json, "MipBias"))
		{
			MipBias = _json.MipBias;
		}

		if (variable_struct_exists(_json, "MipFilter"))
		{
			MipFilter = _json.MipFilter;
		}

		if (variable_struct_exists(_json, "MipMin"))
		{
			MipMin = _json.MipMin;
		}

		if (variable_struct_exists(_json, "MipMax"))
		{
			MipMax = _json.MipMax;
		}

		if (variable_struct_exists(_json, "Anisotropy"))
		{
			Anisotropy = _json.Anisotropy;
		}

		if (variable_struct_exists(_json, "Filtering"))
		{
			Filtering = _json.Filtering;
		}

		if (variable_struct_exists(_json, "Repeat"))
		{
			Repeat = _json.Repeat;
		}

		if (variable_struct_exists(_json, "BaseOpacity"))
		{
			if (__baseOpacitySprite != undefined)
			{
				sprite_delete(__baseOpacitySprite);
				__baseOpacitySprite = undefined;
			}

			BaseOpacity = _json.BaseOpacity;
		}

		return self;
	};

	static to_file = function (_file) {
		var _dirname = filename_dir(_file);
		if (!directory_exists(_dirname))
		{
			directory_create(_dirname);
		}

		var _json = {};
		to_json(_json);

		var _jsonFile = file_text_open_write(_file);
		file_text_write_string(_jsonFile, json_stringify(_json));
		file_text_close(_jsonFile);

		return self;
	};

	static from_file = function (_file, _sha1=undefined) {
		Path = _file;
		check_file(_file, _sha1);
		from_json(bbmod_json_load(_file));
		IsLoaded = true;
		return self;
	};

	static from_file_async = function (_file, _sha1=undefined, _callback=undefined) {
		Path = _file;

		if (!check_file(_file, _sha1, _callback ?? bbmod_empty_callback))
		{
			return self;
		}

		var _json;

		try
		{
			_json = bbmod_json_load(_file);
		}
		catch (_err)
		{
			if (_callback)
			{
				_callback(_err, self);
			}
			return self;
		}

		from_json(_json);
		IsLoaded = true;

		if (_callback != undefined)
		{
			_callback(undefined, self);
		}

		return self;
	};

	static _make_sprite = function (_r, _g, _b, _a) {
		gml_pragma("forceinline");
		static _sur = noone;
		if (!surface_exists(_sur))
		{
			_sur = surface_create(1, 1);
		}
		surface_set_target(_sur);
		draw_clear_alpha(make_color_rgb(_r, _g, _b), _a);
		surface_reset_target();
		return sprite_create_from_surface(_sur, 0, 0, 1, 1, false, false, 0, 0);
	};

	/// @func set_base_opacity(_color)
	///
	/// @desc Changes the base color and opacity to a uniform value for the
	/// entire material.
	///
	/// @param {Struct.BBMOD_Color} _color The new base color and opacity.
	///
	/// @return {Struct.BBMOD_BaseMaterial} Returns `self`.
	static set_base_opacity = function (_color) {
		if (__baseOpacitySprite != undefined)
		{
			sprite_delete(__baseOpacitySprite);
		}
		var _isReal = is_real(_color);
		__baseOpacitySprite = _make_sprite(
			_isReal ? color_get_red(_color) : _color.Red,
			_isReal ? color_get_green(_color) : _color.Green,
			_isReal ? color_get_blue(_color) : _color.Blue,
			_isReal ? argument[1] : _color.Alpha
		);
		BaseOpacity = sprite_get_texture(__baseOpacitySprite, 0);
		return self;
	};

	/// @func apply(_vertexFormat)
	///
	/// @desc Makes this material the current one.
	///
	/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format of
	/// meshes that we are going to use the material for.
	///
	/// @return {Bool} Returns `true` if the material was applied.
	///
	/// @see BBMOD_Material.reset
	static apply = function (_vertexFormat) {
		if ((RenderPass & (1 << bbmod_render_pass_get())) == 0)
		{
			return false;
		}

		var _shader = Shaders[bbmod_render_pass_get()];
		var _shaderRaw = _shader.get_variant(_vertexFormat);

		if (_shaderRaw == undefined)
		{
			__bbmod_warning(
				"Shader variant for vertex format "
				+ string(_vertexFormat.get_hash())
				+ " was not found! Material not applied!");
			return false;
		}

		var _shaderChanged = false;
		if (BBMOD_SHADER_CURRENT != _shader
			|| shader_current() != _shaderRaw)
		{
			if (BBMOD_SHADER_CURRENT != undefined)
			{
				BBMOD_SHADER_CURRENT.reset();
			}
			shader_set(_shaderRaw);
			BBMOD_SHADER_CURRENT = _shader;
			_shaderChanged = true;
		}

		if (global.__bbmodMaterialCurrent != self)
		{
			// TODO: GPU settings override per render pass!
			var _isShadows = (bbmod_render_pass_get() == BBMOD_ERenderPass.Shadows);

			if (global.__bbmodMaterialCurrent != undefined)
			{
				gpu_pop_state();
			}

			gpu_push_state();

			if (_shaderChanged)
			{
				with (_shader)
				{
					on_set();
					__bbmod_shader_set_globals(_shaderRaw);
				}
				_shaderChanged = false;
			}

			gpu_set_blendmode(_isShadows ? bm_normal : BlendMode);
			gpu_set_blendenable(_isShadows ? false : AlphaBlend);
			gpu_set_cullmode(Culling);
			gpu_set_zwriteenable(_isShadows ? true : ZWrite);
			gpu_set_ztestenable(_isShadows ? true : ZTest);
			gpu_set_zfunc(ZFunc);
			gpu_set_tex_mip_enable(Mipmapping);
			gpu_set_tex_mip_bias(MipBias);
			gpu_set_tex_mip_filter(MipFilter);
			gpu_set_tex_min_mip(MipMin);
			gpu_set_tex_max_mip(MipMax);
			gpu_set_tex_max_aniso(Anisotropy);
			gpu_set_tex_filter(Filtering);
			gpu_set_tex_repeat(Repeat);

			_shader.set_material(self);
			global.__bbmodMaterialCurrent = self;
		}

		if (_shaderChanged)
		{
			with (_shader)
			{
				on_set();
				__bbmod_shader_set_globals(_shaderRaw);
			}
			_shader.set_material(self);
		}

		if (OnApply != undefined)
		{
			OnApply(self);
		}

		return true;
	};

	/// @func set_shader(_pass, _shader)
	///
	/// @desc Defines a shader used in a specific render pass.
	///
	/// @param {Real} _pass The render pass. Use values from {@link BBMOD_ERenderPass}.
	/// @param {Struct.BBMOD_Shader} _shader The shader used in the render pass.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	///
	/// @see BBMOD_Material.get_shader
	/// @see bbmod_render_pass_set
	static set_shader = function (_pass, _shader) {
		gml_pragma("forceinline");
		RenderPass |= (1 << _pass);
		Shaders[@ _pass] = _shader;
		return self;
	};

	/// @func has_shader(_pass)
	///
	/// @desc Checks whether the material has a shader for the render pass.
	///
	/// @param {Real} _pass The render pass. Use values from {@link BBMOD_ERenderPass}.
	///
	/// @return {Bool} Returns `true` if the material has a shader for the
	/// render pass.
	static has_shader = function (_pass) {
		gml_pragma("forceinline");
		return ((RenderPass & (1 << _pass)) != 0);
	};

	/// @func get_shader(_pass)
	///
	/// @desc Retrieves a shader used in a specific render pass.
	///
	/// @param {Real} _pass The render pass. Use values from
	/// {@link BBMOD_ERenderPass}.
	///
	/// @return {Struct.BBMOD_Shader} The shader or `undefined`.
	///
	/// @see BBMOD_Material.set_shader
	static get_shader = function (_pass) {
		gml_pragma("forceinline");
		return Shaders[_pass];
	};

	/// @func remove_shader(_pass)
	///
	/// @desc Removes a shader used in a specific render pass.
	///
	/// @param {Real} _pass The render pass.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static remove_shader = function (_pass) {
		gml_pragma("forceinline");
		RenderPass &= ~(1 << _pass);
		Shaders[@ _pass] = undefined;
		return self;
	};

	/// @func reset()
	///
	/// @desc Resets the current material to `undefined`.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	///
	/// @see BBMOD_Material.apply
	/// @see bbmod_material_reset
	static reset = function () {
		gml_pragma("forceinline");
		bbmod_material_reset();
		return self;
	};

	static destroy = function () {
		Resource_destroy();
		if (__baseOpacitySprite != undefined)
		{
			sprite_delete(__baseOpacitySprite);
		}
		return undefined;
	};

	if (_shader != undefined)
	{
		set_shader(BBMOD_ERenderPass.Forward, _shader);
	}
}

/// @func bbmod_material_reset()
///
/// @desc Resets the current material to `undefined`. Every block of code
/// rendering models must start and end with this function!
///
/// @example
/// ```gml
/// bbmod_material_reset();
///
/// // Render static batch of trees
/// treeBatch.submit(matTree);
///
/// // Render characters
/// var _world = matrix_get(matrix_world);
/// with (OCharacter)
/// {
///     matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, direction, 1, 1, 1));
///     animationPlayer.submit();
/// }
/// matrix_set(matrix_world, _world);
///
/// bbmod_material_reset();
/// ```
/// @see BBMOD_Material.reset
function bbmod_material_reset()
{
	gml_pragma("forceinline");
	if (global.__bbmodMaterialCurrent != undefined)
	{
		gpu_pop_state();
		global.__bbmodMaterialCurrent = undefined;
	}
	if (BBMOD_SHADER_CURRENT != undefined)
	{
		BBMOD_SHADER_CURRENT.reset();
	}
}
