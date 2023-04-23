/// @func BBMOD_OutOfRangeException([_msg])
///
/// @extends BBMOD_Exception
///
/// @desc An exception thrown when you try to read a value from a data structure
/// at an index which is out of its range.
///
/// @param {string} [_msg] The exception message. Defaults to "Index out of
/// range!".
function BBMOD_OutOfRangeException(_msg="Index out of range!")
	: BBMOD_Exception(_msg) constructor
{
	BBMOD_CLASS_GENERATED_BODY;
}
