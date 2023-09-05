/// @macro {String} Path to the GMD3D11 dynamic library.
/// Default value is "GMD3D11.dll".
#macro GMD3D11_PATH "GMD3D11.dll"

/// @macro {Bool} Expands to `true` if GMD3D11 is supported on the current
/// platform.
#macro GMD3D11_IS_SUPPORTED (os_type == os_windows)

/// @func d3d11_get_error_string()
///
/// @desc Retrieves the last error message.
///
/// @return {String} The last error message.
function d3d11_get_error_string()
{
	gml_pragma("forceinline");
	static _fn = external_define(
		GMD3D11_PATH, "d3d11_get_error_string", dll_cdecl, ty_string,
		0);
	return external_call(_fn);
}

/// @func d3d11_texture_set_stage_vs(_slot, _texture)
///
/// @desc Passes a texture to a vertex shader.
///
/// @param {Real} _slot The vertex texture slot index. Must be in range
/// 0..{@link D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT}-1.
/// @param {Pointer.Texture} _texture The texture to pass.
///
/// @return {Real} Returns 1 on success or 0 on fail.
function d3d11_texture_set_stage_vs(_slot, _texture)
{
	gml_pragma("forceinline");
	static _fn = external_define(
		GMD3D11_PATH, "d3d11_texture_set_stage_vs", dll_cdecl, ty_real,
		1, ty_real);
	texture_set_stage(0, _texture);
	return external_call(_fn, _slot);
}

/// @func texture_set_stage_vs(_slot, _texture)
///
/// @desc If GMD3D11 is supported, then uses {@link d3d11_texture_set_stage_vs}
/// to pass a texture to a vertex shader, otherwise uses `texture_set_stage`
/// (which should work on OpenGL platforms).
///
/// @param {Real} _slot The vertex texture slot index. Must be in range 0..7.
/// @param {Pointer.Texture} _texture The texture to pass.
///
/// @see GMD3D11_IS_SUPPORTED
function texture_set_stage_vs(_slot, _texture)
{
	gml_pragma("forceinline");
	if (GMD3D11_IS_SUPPORTED)
	{
		d3d11_texture_set_stage_vs(_slot, _texture);
		return;
	}
	texture_set_stage(_slot, _texture);
}

/// @func d3d11_texture_set_stage_ps(_slot, _texture)
///
/// @desc Passes a texture to a pixel shader.
///
/// @param {Real} _slot The pixel texture slot index. Must be in range
/// 0..{@link D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT}-1.
/// @param {Pointer.Texture} _texture The texture to pass.
///
/// @return {Real} Returns 1 on success or 0 on fail.
function d3d11_texture_set_stage_ps(_slot, _texture)
{
	gml_pragma("forceinline");
	static _fn = external_define(
		GMD3D11_PATH, "d3d11_texture_set_stage_ps", dll_cdecl, ty_real,
		1, ty_real);
	texture_set_stage(0, _texture);
	return external_call(_fn, _slot);
}

/// @func d3d11_draw_instanced(_count)
///
/// @desc Configures the number of instances to draw the next time a vertex buffer
/// is submitted. After that the number is reset back to 0!
///
/// @param {Real} _count Number of instances to draw. Use 0 to disable instanced rendering.
function d3d11_draw_instanced(_count)
{
	gml_pragma("forceinline");
	static _fn = external_define(
		GMD3D11_PATH, "d3d11_draw_instanced", dll_cdecl, ty_real,
		1, ty_real);
	return external_call(_fn, _count);
}

/// @func vertex_submit_instanced(_vbuff, _prim, _texture, _count)
///
/// @desc Draws multiple instances of a vertex buffer.
///
/// @param {Id.VertexBuffer} _vbuff The vertex buffer to submit.
/// @param {Constant.PrimitiveType} _prim The primitive type.
/// @param {Pointer.Texture} _texture The texture to use.
/// @param {Real} _count The number of instances to draw.
function vertex_submit_instanced(_vbuff, _prim, _texture, _count)
{
	gml_pragma("forceinline");
	if (!d3d11_draw_instanced(_count))
	{
		return false;
	}
	vertex_submit(_vbuff, _prim, _texture);
	return true;
}

if (GMD3D11_IS_SUPPORTED)
{
	var _init = external_define(
		GMD3D11_PATH, "d3d11_init", dll_cdecl, ty_real, 2, ty_string, ty_string);
	var _osInfo = os_get_info();
	var _device = _osInfo[? "video_d3d11_device"];
	var _context = _osInfo[? "video_d3d11_context"];
	external_call(_init, _device, _context);
}
