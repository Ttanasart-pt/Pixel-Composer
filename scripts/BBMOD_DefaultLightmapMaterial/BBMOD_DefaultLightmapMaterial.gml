/// @func BBMOD_DefaultLightmapMaterial([_shader])
///
/// @extends BBMOD_DefaultMaterial
///
/// @desc A material that can be used when rendering lightmapped models with
/// two UV channels.
///
/// @param {Struct.BBMOD_LightmapShader} [_shader] A shader that the material
/// uses in the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you
/// would like to use {@link BBMOD_Material.set_shader} to specify shaders
/// used in specific render passes.
///
/// @see BBMOD_LightmapShader
function BBMOD_DefaultLightmapMaterial(_shader=undefined)
	: BBMOD_DefaultMaterial(_shader) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static DefaultMaterial_copy = copy;

	/// @var {Pointer.Texture} A texture with RGBM encoded lightmap. Overrides
	/// the default lightmap texture defined with {@link bbmod_lightmap_set}.
	Lightmap = undefined;

	static copy = function (_dest) {
		DefaultMaterial_copy(_dest);
		_dest.Lightmap = Lightmap;
		return self;
	};

	static clone = function () {
		var _clone = new BBMOD_DefaultLightmapMaterial();
		copy(_clone);
		return _clone;
	};
}
