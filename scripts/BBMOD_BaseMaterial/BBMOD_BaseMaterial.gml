/// @func BBMOD_BaseMaterial([_shader])
///
/// @extends BBMOD_Material
///
/// @desc A material that can be used when rendering models.
///
/// @param {Struct.BBMOD_Shader} [_shader] A shader that the material uses in
/// the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you would
/// like to use {@link BBMOD_Material.set_shader} to specify shaders used in
/// specific render passes.
///
/// @see BBMOD_Shader
function BBMOD_BaseMaterial(_shader=undefined)
	: BBMOD_Material(_shader) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Material_copy = copy;
	static Material_to_json = to_json;
	static Material_from_json = from_json;

	/// @var {Struct.BBMOD_Color} Multiplier for {@link BBMOD_Material.BaseOpacity}.
	/// Default value is {@link BBMOD_C_WHITE}.
	BaseOpacityMultiplier = BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Vec2} An offset of texture UV coordinates. Defaults
	/// to `(0, 0)`. Using this you can control texture's position within texture
	/// page.
	TextureOffset = new BBMOD_Vec2(0.0);

	/// @var {Struct.BBMOD_Vec2} A scale of texture UV coordinates. Defaults to
	/// `(1, 1)`.
	/// Using this you can control texture's size within texture page.
	TextureScale = new BBMOD_Vec2(1.0);

	/// @var {Real} Controls range over which the mesh smoothly transitions into
	/// shadow. This can be useful for example for billboarded particles, where
	/// harsh transition does not look good. Default value is 0, which means no
	/// smooth transition.
	ShadowmapBias = 0.0;

	static copy = function (_dest) {
		Material_copy(_dest);
		BaseOpacityMultiplier.Copy(_dest.BaseOpacityMultiplier);
		_dest.TextureOffset = TextureOffset.Clone();
		_dest.TextureScale = TextureScale.Clone();
		_dest.ShadowmapBias = ShadowmapBias;
		return self;
	};

	static clone = function () {
		var _clone = new BBMOD_BaseMaterial();
		copy(_clone);
		return _clone;
	};

	static to_json = function (_json) {
		Material_to_json(_json);

		_json.BaseOpacityMultiplier = {
			Red: BaseOpacityMultiplier.Red,
			Green: BaseOpacityMultiplier.Green,
			Blue: BaseOpacityMultiplier.Blue,
			Alpha: BaseOpacityMultiplier.Alpha,
		};

		_json.TextureOffset = {
			X: TextureOffset.X,
			Y: TextureOffset.Y,
		};

		_json.TextureScale = {
			X: TextureScale.X,
			Y: TextureScale.Y,
		};

		_json.ShadowmapBias = ShadowmapBias;

		return self;
	};

	static from_json = function (_json) {
		Material_from_json(_json);

		var _baseOpacityMultiplier = _json[$ "BaseOpacityMultiplier"];
		if (_baseOpacityMultiplier != undefined)
		{
			BaseOpacityMultiplier = new BBMOD_Color(
				_baseOpacityMultiplier.Red,
				_baseOpacityMultiplier.Green,
				_baseOpacityMultiplier.Blue,
				_baseOpacityMultiplier.Alpha
			);
		}

		var _textureOffset = _json[$ "TextureOffset"];
		if (_textureOffset != undefined)
		{
			TextureOffset = new BBMOD_Vec2(
				_textureOffset.X,
				_textureOffset.Y
			);
		}

		var _textureScale = _json[$ "TextureScale"];
		if (_textureScale != undefined)
		{
			TextureScale = new BBMOD_Vec2(
				_textureScale.X,
				_textureScale.Y
			);
		}

		if (variable_struct_exists(_json, "ShadowmapBias"))
		{
			ShadowmapBias = _json.ShadowmapBias;
		}

		return self;
	};
}
