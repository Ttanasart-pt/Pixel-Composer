/// @func BBMOD_DefaultMaterial([_shader])
///
/// @extends BBMOD_BaseMaterial
///
/// @desc A material that can be used when rendering models.
///
/// @param {Struct.BBMOD_DefaultShader} [_shader] A shader that the material
/// uses in the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you
/// would like to use {@link BBMOD_Material.set_shader} to specify shaders used
/// in specific render passes.
///
/// @see BBMOD_DefaultShader
function BBMOD_DefaultMaterial(_shader=undefined)
	: BBMOD_BaseMaterial(_shader) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static BaseMaterial_copy = copy;
	static BaseMaterial_from_json = from_json;
	static BaseMaterial_destroy = destroy;

	/// @var {Pointer.Texture} A texture with tangent-space normals in the RGB
	/// channels and smoothness in the alpha channel or `undefined`.
	NormalSmoothness = sprite_get_texture(BBMOD_SprDefaultNormalW, 0);

	__normalSmoothnessSprite = undefined;

	/// @var {Pointer.Texture} A texture specular color in the RGB channels
	/// or `undefined`.
	SpecularColor = sprite_get_texture(BBMOD_SprDefaultSpecularColor, 0);

	__specularColorSprite = undefined;

	/// @var {Pointer.Texture} A texture with tangent-space normals in the RGB
	/// channels and roughness in the alpha channel or `undefined`.
	NormalRoughness = undefined;

	__normalRoughnessSprite = undefined;

	/// @var {Pointer.Texture} A texture with metallic in the red channel and
	/// ambient occlusion in the green channel or `undefined`.
	MetallicAO = undefined;

	__metallicAOSprite = undefined;

	/// @var {Pointer.Texture} A texture with subsurface color in the RGB
	/// channels and subsurface effect intensity in the alpha channel.
	Subsurface = sprite_get_texture(BBMOD_SprBlack, 0);

	__subsurfaceSprite = undefined;

	/// @var {Pointer.Texture} RGBM encoded emissive texture.
	Emissive = sprite_get_texture(BBMOD_SprBlack, 0);

	__emissiveSprite = undefined;

	// TODO: Add to_json

	static from_json = function (_json) {
		BaseMaterial_from_json(_json);

		if (variable_struct_exists(_json, "NormalSmoothness"))
		{
			if (__normalSmoothnessSprite != undefined)
			{
				sprite_delete(__normalSmoothnessSprite);
				__normalSmoothnessSprite = undefined;
			}

			NormalSmoothness = _json.NormalSmoothness;
		}

		if (variable_struct_exists(_json, "SpecularColor"))
		{
			if (__specularColorSprite != undefined)
			{
				sprite_delete(__specularColorSprite);
				__specularColorSprite = undefined;
			}

			SpecularColor = _json.SpecularColor;
		}

		if (variable_struct_exists(_json, "NormalRoughness"))
		{
			if (__normalRoughnessSprite != undefined)
			{
				sprite_delete(__normalRoughnessSprite);
				__normalRoughnessSprite = undefined;
			}

			NormalRoughness = _json.NormalRoughness;
		}

		if (variable_struct_exists(_json, "MetallicAO"))
		{
			if (__metallicAOSprite != undefined)
			{
				sprite_delete(__metallicAOSprite);
				__metallicAOSprite = undefined;
			}

			MetallicAO = _json.MetallicAO;
		}

		if (variable_struct_exists(_json, "Subsurface"))
		{
			if (__subsurfaceSprite != undefined)
			{
				sprite_delete(__subsurfaceSprite);
				__subsurfaceSprite = undefined;
			}

			Subsurface = _json.Subsurface;
		}

		if (variable_struct_exists(_json, "Emissive"))
		{
			if (__emissiveSprite != undefined)
			{
				sprite_delete(__emissiveSprite);
				__emissiveSprite = undefined;
			}

			Emissive = _json.Emissive;
		}

		return self;
	};

	/// @func set_normal_smoothness(_normal, _smoothness)
	///
	/// @desc Changes the normal vector and smoothness to a uniform value for
	/// the entire material.
	///
	/// @param {Struct.BBMOD_Vec3} _normal The new normal vector. If you are not
	/// sure what this value should be, use {@link BBMOD_VEC3_UP}.
	/// @param {Real} _smoothness The new smoothness. Use values in range 0..1.
	///
	/// @return {Struct.BBMOD_DefaultMaterial} Returns `self`.
	static set_normal_smoothness = function (_normal, _smoothness) {
		NormalRoughness = undefined;
		if (__normalRoughnessSprite != undefined)
		{
			sprite_delete(__normalRoughnessSprite);
			__normalRoughnessSprite = undefined;
		}

		if (__normalSmoothnessSprite != undefined)
		{
			sprite_delete(__normalSmoothnessSprite);
		}
		_normal = _normal.Normalize();
		__normalSmoothnessSprite = _make_sprite(
			(_normal.X * 0.5 + 0.5) * 255.0,
			(_normal.Y * 0.5 + 0.5) * 255.0,
			(_normal.Z * 0.5 + 0.5) * 255.0,
			_smoothness
		);
		NormalSmoothness = sprite_get_texture(__normalSmoothnessSprite, 0);
		return self;
	};

	/// @func set_specular_color(_color)
	///
	/// @desc Changes the specular color to a uniform value for the entire
	/// material.
	///
	/// @param {Struct.BBMOD_Color} _color The new specular color.
	///
	/// @return {Struct.BBMOD_DefaultMaterial} Returns `self`.
	static set_specular_color = function (_color) {
		MetallicAO = undefined;
		if (__metallicAOSprite != undefined)
		{
			sprite_delete(__metallicAOSprite);
			__metallicAOSprite = undefined;
		}

		if (__specularColorSprite != undefined)
		{
			sprite_delete(__specularColorSprite);
		}
		__specularColorSprite = _make_sprite(
			_color.Red,
			_color.Green,
			_color.Blue,
			1.0
		);
		SpecularColor = sprite_get_texture(__specularColorSprite, 0);
		return self;
	};

	/// @func set_normal_roughness(_normal, _roughness)
	///
	/// @desc Changes the normal vector and roughness to a uniform value for the
	/// entire material.
	///
	/// @param {Struct.BBMOD_Vec3} _normal The new normal vector. If you are not
	/// sure what this value should be, use {@link BBMOD_VEC3_UP}.
	/// @param {Real} _roughness The new roughness. Use values in range 0..1.
	///
	/// @return {Struct.BBMOD_PBRMaterial} Returns `self`.
	static set_normal_roughness = function (_normal, _roughness) {
		NormalSmoothness = undefined;
		if (__normalSmoothnessSprite != undefined)
		{
			sprite_delete(__normalSmoothnessSprite);
			__normalSmoothnessSprite = undefined;
		}

		if (__normalRoughnessSprite != undefined)
		{
			sprite_delete(__normalRoughnessSprite);
		}
		_normal = _normal.Normalize();
		__normalRoughnessSprite = _make_sprite(
			(_normal.X * 0.5 + 0.5) * 255.0,
			(_normal.Y * 0.5 + 0.5) * 255.0,
			(_normal.Z * 0.5 + 0.5) * 255.0,
			_roughness
		);
		NormalRoughness = sprite_get_texture(__normalRoughnessSprite, 0);
		return self;
	};

	/// @func set_metallic_ao(_metallic, _ao)
	///
	/// @desc Changes the metalness and ambient occlusion to a uniform value for
	/// the entire material.
	///
	/// @param {Real} _metallic The new metalness. You can use any value in range
	/// 0..1, but in general this is usually either 0 for dielectric materials
	/// and 1 for metals.
	/// @param {Real} _ao The new ambient occlusion value. Use values in range
	/// 0..1, where 0 means full occlusion and 1 means no occlusion.
	///
	/// @return {Struct.BBMOD_PBRMaterial} Returns `self`.
	static set_metallic_ao = function (_metallic, _ao) {
		SpecularColor = undefined;
		if (__specularColorSprite != undefined)
		{
			sprite_delete(__specularColorSprite);
			__specularColorSprite = undefined;
		}

		if (__metallicAOSprite != undefined)
		{
			sprite_delete(__metallicAOSprite);
		}
		__metallicAOSprite = _make_sprite(
			_metallic * 255.0,
			_ao * 255.0,
			0.0,
			0.0
		);
		MetallicAO = sprite_get_texture(__metallicAOSprite, 0);
		return self;
	};

	/// @func set_subsurface(_color, _intensity)
	///
	/// @desc Changes the subsurface color to a uniform value for the entire
	/// material.
	///
	/// @param {Real} _color The new subsurface color.
	/// @param {Real} _intensity The subsurface color intensity. Use values in
	/// range 0..1. The higher the value, the more visible the effect is.
	///
	/// @return {Struct.BBMOD_PBRMaterial} Returns `self`.
	static set_subsurface = function (_color, _intensity) {
		if (__subsurfaceSprite != undefined)
		{
			sprite_delete(__subsurfaceSprite);
		}
		__subsurfaceSprite = _make_sprite(
			color_get_red(_color),
			color_get_green(_color),
			color_get_blue(_color),
			_intensity
		);
		Subsurface = sprite_get_texture(__subsurfaceSprite, 0);
		return self;
	};

	/// @func set_emissive(_color)
	///
	/// @desc Changes the emissive color to a uniform value for the entire
	/// material.
	///
	/// @param {Struct.BBMOD_Color} _color The new emissive color.
	///
	/// @return {Struct.BBMOD_PBRMaterial} Returns `self`.
	static set_emissive = function () {
		var _color = (argument_count == 3)
			? new BBMOD_Color(argument[0], argument[1], argument[2])
			: argument[0];
		var _rgbm = _color.ToRGBM();
		if (__emissiveSprite != undefined)
		{
			sprite_delete(__emissiveSprite);
		}
		__emissiveSprite = _make_sprite(
			_rgbm[0] * 255.0,
			_rgbm[1] * 255.0,
			_rgbm[2] * 255.0,
			_rgbm[3]
		);
		Emissive = sprite_get_texture(__emissiveSprite, 0);
		return self;
	};

	static copy = function (_dest) {
		BaseMaterial_copy(_dest);

		// NormalSmoothness
		if (_dest.__normalSmoothnessSprite != undefined)
		{
			sprite_delete(_dest.__normalSmoothnessSprite);
			_dest.__normalSmoothnessSprite = undefined;
		}

		if (__normalSmoothnessSprite != undefined)
		{
			_dest.__normalSmoothnessSprite = sprite_duplicate(__normalSmoothnessSprite);
			_dest.NormalSmoothness = sprite_get_texture(_dest.__normalSmoothnessSprite, 0);
		}
		else
		{
			_dest.NormalSmoothness = NormalSmoothness;
		}

		// SpecularColor
		if (_dest.__specularColorSprite != undefined)
		{
			sprite_delete(_dest.__specularColorSprite);
			_dest.__specularColorSprite = undefined;
		}

		if (__specularColorSprite != undefined)
		{
			_dest.__specularColorSprite = sprite_duplicate(__specularColorSprite);
			_dest.SpecularColor = sprite_get_texture(_dest.__specularColorSprite, 0);
		}
		else
		{
			_dest.SpecularColor = SpecularColor;
		}

		// NormalRoughness
		if (_dest.__normalRoughnessSprite != undefined)
		{
			sprite_delete(_dest.__normalRoughnessSprite);
			_dest.__normalRoughnessSprite = undefined;
		}

		if (__normalRoughnessSprite != undefined)
		{
			_dest.__normalRoughnessSprite = sprite_duplicate(__normalRoughnessSprite);
			_dest.NormalRoughness = sprite_get_texture(_dest.__normalRoughnessSprite, 0);
		}
		else
		{
			_dest.NormalRoughness = NormalRoughness;
		}

		// MetallicAO
		if (_dest.__metallicAOSprite != undefined)
		{
			sprite_delete(_dest.__metallicAOSprite);
			_dest.__metallicAOSprite = undefined;
		}

		if (__metallicAOSprite != undefined)
		{
			_dest.__metallicAOSprite = sprite_duplicate(__metallicAOSprite);
			_dest.MetallicAO = sprite_get_texture(_dest.__metallicAOSprite, 0);
		}
		else
		{
			_dest.MetallicAO = MetallicAO;
		}

		// Subsurface
		if (_dest.__subsurfaceSprite != undefined)
		{
			sprite_delete(_dest.__subsurfaceSprite);
			_dest.__subsurfaceSprite = undefined;
		}

		if (__subsurfaceSprite != undefined)
		{
			_dest.__subsurfaceSprite = sprite_duplicate(__subsurfaceSprite);
			_dest.Subsurface = sprite_get_texture(_dest.__subsurfaceSprite, 0);
		}
		else
		{
			_dest.Subsurface = Subsurface;
		}

		// Emissive
		if (_dest.__emissiveSprite != undefined)
		{
			sprite_delete(_dest.__emissiveSprite);
			_dest.__emissiveSprite = undefined;
		}

		if (__emissiveSprite != undefined)
		{
			_dest.__emissiveSprite = sprite_duplicate(__emissiveSprite);
			_dest.Emissive = sprite_get_texture(_dest.__emissiveSprite, 0);
		}
		else
		{
			_dest.Emissive = Emissive;
		}

		return self;
	};

	static clone = function () {
		var _clone = new BBMOD_DefaultMaterial();
		copy(_clone);
		return _clone;
	};

	static destroy = function () {
		BaseMaterial_destroy();
		if (__normalSmoothnessSprite != undefined)
		{
			sprite_delete(__normalSmoothnessSprite);
		}
		if (__specularColorSprite != undefined)
		{
			sprite_delete(__specularColorSprite);
		}
		if (__normalRoughnessSprite != undefined)
		{
			sprite_delete(__normalRoughnessSprite);
		}
		if (__metallicAOSprite != undefined)
		{
			sprite_delete(__metallicAOSprite);
		}
		if (__subsurfaceSprite != undefined)
		{
			sprite_delete(__subsurfaceSprite);
		}
		if (__emissiveSprite != undefined)
		{
			sprite_delete(__emissiveSprite);
		}
		return undefined;
	};
}
