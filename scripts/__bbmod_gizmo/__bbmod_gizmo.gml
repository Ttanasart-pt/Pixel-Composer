/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
/// @see BBMOD_BaseShader
#macro BBMOD_SHADER_INSTANCE_ID __bbmod_shader_id()

function __bbmod_shader_id()
{
	static _shader = new BBMOD_BaseShader(
		             BBMOD_ShInstanceID,         BBMOD_VFORMAT_DEFAULT)
		.add_variant(BBMOD_ShInstanceIDAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED)
		.add_variant(BBMOD_ShInstanceIDBatched,  BBMOD_VFORMAT_DEFAULT_BATCHED)
		.add_variant(BBMOD_ShInstanceIDLightmap, BBMOD_VFORMAT_DEFAULT_LIGHTMAP);
	return _shader;
}

////////////////////////////////////////////////////////////////////////////////
// DEPRECATED!!!

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
/// @see BBMOD_BaseShader
/// @deprecated Please use {@link BBMOD_SHADER_INSTANCE_ID} instead.
#macro BBMOD_SHADER_INSTANCE_ID_ANIMATED BBMOD_SHADER_INSTANCE_ID

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs.
/// @see BBMOD_BaseShader
/// @deprecated Please use {@link BBMOD_SHADER_INSTANCE_ID} instead.
#macro BBMOD_SHADER_INSTANCE_ID_BATCHED BBMOD_SHADER_INSTANCE_ID

/// @macro {Struct.BBMOD_BaseShader} A shader used when rendering instance IDs
/// for lightmapped models.
/// @see BBMOD_BaseShader
/// @deprecated Please use {@link BBMOD_SHADER_INSTANCE_ID_LIGHTMAP} instead.
#macro BBMOD_SHADER_LIGHTMAP_INSTANCE_ID BBMOD_SHADER_INSTANCE_ID

bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID",          BBMOD_SHADER_INSTANCE_ID);
bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID_ANIMATED", BBMOD_SHADER_INSTANCE_ID_ANIMATED);
bbmod_shader_register("BBMOD_SHADER_INSTANCE_ID_BATCHED",  BBMOD_SHADER_INSTANCE_ID_BATCHED);
bbmod_shader_register("BBMOD_SHADER_LIGHTMAP_INSTANCE_ID", BBMOD_SHADER_LIGHTMAP_INSTANCE_ID);
