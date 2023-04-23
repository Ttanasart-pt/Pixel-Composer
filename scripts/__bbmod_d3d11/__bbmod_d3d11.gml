/// @func __bbmod_d3d11_init()
///
/// @return {Bool} Returns `true` if BBMOD.dll is available and D3D11 is
/// initialized.
///
/// @private
function __bbmod_d3d11_init()
{
	gml_pragma("forceinline");
	static _isSupported = undefined;
	if (_isSupported == undefined)
	{
		if (os_type == os_windows && file_exists(BBMOD_DLL_PATH))
		{
			var _init = external_define(
				BBMOD_DLL_PATH, "bbmod_d3d11_init", dll_cdecl, ty_real, 2, ty_string, ty_string);
			var _osInfo = os_get_info();
			var _device = _osInfo[? "video_d3d11_device"];
			var _context = _osInfo[? "video_d3d11_context"];
			_isSupported = external_call(_init, _device, _context);
		}
		else
		{
			_isSupported = false;
		}
	}
	return _isSupported;
}

/// @func bbmod_texture_set_stage_vs(_slot, _texture)
///
/// @desc Passes a texture to a vertex shader. On Windows this uses BBMOD.dll
/// (if available), oterwise GameMaker's built-in `texture_set_stage` is used,
/// which should work on OpenGL-based platforms.
///
/// @param {Real} _slot The vertex texture slot index. Must be in range 0..7.
/// @param {Pointer.Texture} _texture The texture to pass.
///
/// @note You can test if this function is supported with
/// {@link bbmod_vtf_is_supported}.
///
/// @see bbmod_vtf_is_supported
function bbmod_texture_set_stage_vs(_slot, _texture)
{
	gml_pragma("forceinline");
	if (__bbmod_d3d11_init())
	{
		static _fn = external_define(
			BBMOD_DLL_PATH, "bbmod_d3d11_texture_set_stage_vs", dll_cdecl, ty_real,
			1, ty_real);
		texture_set_stage(0, _texture);
		external_call(_fn, _slot);
	}
	else
	{
		texture_set_stage(_slot, _texture);
	}
}
