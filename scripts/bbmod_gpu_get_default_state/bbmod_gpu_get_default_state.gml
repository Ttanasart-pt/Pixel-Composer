/// @func bbmod_gpu_get_default_state()
///
/// @desc Retrieves the default GPU state.
///
/// @return {Id.DsMap} The default GPU state.
function bbmod_gpu_get_default_state()
{
	static _state = gpu_get_state();
	return _state;
}

bbmod_gpu_get_default_state();
