/// @func BBMOD_Exception([_msg])
///
/// @extends BBMOD_Class
///
/// @desc The base struct for exceptions thrown by the BBMOD library.
///
/// @param {String} [_msg] An exception message. Defaults to an empty string.
function BBMOD_Exception(_msg="")
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {string} The exception message.
	/// @readonly
	Message = _msg;
}
