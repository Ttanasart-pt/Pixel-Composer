/// @func bbmod_get_calling_function_name()
///
/// @desc Retrieves name of the calling function.
///
/// @return {String} The name of the calling function.
function bbmod_get_calling_function_name()
{
	gml_pragma("forceinline");
	var _name = debug_get_callstack(/*2*/)[1]; // TODO: Check if this argument works in YYC already
	_name = string_replace(_name, "gml_Script_", "");
	var _pos = string_pos(":", _name);
	if (_pos > 0)
	{
		_name = string_copy(_name, 1, _pos - 1);
	}
	return _name;
}
