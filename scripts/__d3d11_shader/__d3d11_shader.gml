/// @macro {Real} Maximum number of slots for shader resources.
#macro D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT 128

/// @func d3d11_shader_compile_ps(_file, _entryPoint, _profile)
///
/// @desc Compiles a pixel shader from file.
///
/// @param {String} _file The path to file to compile.
/// @param {String} _entryPoint The name of the entry point function, e.g. "main".
/// @param {String} _profile The pixel shader profile, e.g. "ps_4_0".
///
/// @return {Real} The ID of the pixel shader or -1 on fail.
///
/// @see d3d11_get_error_string
function d3d11_shader_compile_ps(_file, _entryPoint, _profile) {
	if(!GMD3D11_IS_SUPPORTED) return;
	INLINE
	static _fn = external_define( GMD3D11_PATH, "d3d11_shader_compile_ps", dll_cdecl, ty_real, 3, ty_string, ty_string, ty_string);
	return external_call(_fn, _file, _entryPoint, _profile);
}

/// @func d3d11_shader_compile_vs(_file, _entryPoint, _profile)
///
/// @desc Compiles a vertex shader from file.
///
/// @param {String} _file The path to file to compile.
/// @param {String} _entryPoint The name of the entry point function, e.g. "main".
/// @param {String} _profile The vertex shader profile, e.g. "vs_4_0".
///
/// @return {Real} The ID of the vertex shader or -1 on fail.
///
/// @see d3d11_get_error_string
function d3d11_shader_compile_vs(_file, _entryPoint, _profile) {
	if(!GMD3D11_IS_SUPPORTED) return;
	INLINE
	static _fn = external_define( GMD3D11_PATH, "d3d11_shader_compile_vs", dll_cdecl, ty_real, 3, ty_string, ty_string, ty_string);
	return external_call(_fn, _file, _entryPoint, _profile);
}

/// @func d3d11_shader_override_ps(_ps)
///
/// @desc Hooks into `ID3D11DeviceContext::Draw` and replaces the current pixel
/// shader with a custom one.
///
/// @param {Real} _ps The ID of the shader or -1 to disable the override.
function d3d11_shader_override_ps(_ps) {
	if(!GMD3D11_IS_SUPPORTED) return;
	INLINE
	static _fn = external_define( GMD3D11_PATH, "d3d11_shader_override_ps", dll_cdecl, ty_real, 1, ty_real);
	return external_call(_fn, _ps);
}

/// @func d3d11_shader_override_vs(_vs)
///
/// @desc Hooks into `ID3D11DeviceContext::Draw` and replaces the current vertex
/// shader with a custom one.
///
/// @param {Real} _vs The ID of the shader or -1 to disable the override. The
/// vertex format expected by the shader must be compatible with the overriden
/// shader!
function d3d11_shader_override_vs(_vs) {
	if(!GMD3D11_IS_SUPPORTED) return;
	INLINE
	static _fn = external_define( GMD3D11_PATH, "d3d11_shader_override_vs", dll_cdecl, ty_real, 1, ty_real);
	return external_call(_fn, _vs);
}

/// @func d3d11_shader_exists(_shader)
///
/// @desc Checks whether a shader exists.
///
/// @param {Real} _ps The ID of the shader.
///
/// @return {Bool} Returns true if the shader exists.
function d3d11_shader_exists(_shader) {
	if(!GMD3D11_IS_SUPPORTED) return;
	INLINE
	static _fn = external_define( GMD3D11_PATH, "d3d11_shader_exists", dll_cdecl, ty_real, 1, ty_real);
	return external_call(_fn, _shader);
}

/// @func d3d11_shader_destroy(_shader)
///
/// @desc Destroys a shader.
///
/// @param {Real} _shader The ID of the shader to destroy.
function d3d11_shader_destroy(_shader) {
	if(!GMD3D11_IS_SUPPORTED) return;
	INLINE
	static _fn = external_define( GMD3D11_PATH, "d3d11_shader_destroy", dll_cdecl, ty_real, 1, ty_real);
	return external_call(_fn, _shader);
}
