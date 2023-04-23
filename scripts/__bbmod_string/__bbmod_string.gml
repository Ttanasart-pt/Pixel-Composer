/// @func bbmod_string_starts_with(_string, _substr)
///
/// @desc Checks whether a string starts with a substring.
///
/// @param {String} _string The string to check.
/// @param {String} _substr The substring.
///
/// @return {Bool} Returns `true` if the string starts with the substring.
function bbmod_string_starts_with(_string, _substr)
{
	gml_pragma("forceinline");
	return (string_pos(_substr, _string) == 1);
}

/// @func bbmod_string_split_on_first(_string, _delimiter[, _dest])
///
/// @desc Splits the string in two at the first occurrence of the delimiter.
///
/// @param {String} _string The string to split.
/// @param {String} _delimiter The delimiter.
/// @param {Array<String>} [_dest] The destination array. A new one is created
/// if not specified.
///
/// @return {Array<String>} An array containing `[firstHalf, secondHalf]`. If
/// the delimiter is not found in the string, then `secondHalf` equals an empty
/// string and `firstHalf` is the original string.
function bbmod_string_split_on_first(_string, _delimiter, _dest=[])
{
	var i = string_pos(_delimiter, _string);
	if (i == 0)
	{
		_dest[@ 0] = _string;
		_dest[@ 1] = "";
	}
	else
	{
		_dest[@ 0] = string_copy(_string, 1, i - 1);
		_dest[@ 1] = string_delete(_string, 1, i);
	}
	return _dest;
}

/// @func bbmod_string_explode(_string, _char, _dest)
///
/// @desc Splits given string on every occurrence of given character and puts
/// created parts into an an array.
///
/// @param {String} _string The string to explode.
/// @param {String} _char The character to split the string on.
/// @param {Array<String>} _dest The destination array.
///
/// @return {Real} Returns number of entries written into the destination array.
function bbmod_string_explode(_string, _char, _dest)
{
	static _temp = array_create(2);
	var i = 0;
	do
	{
		bbmod_string_split_on_first(_string, _char, _temp);
		_dest[@ i++] = _temp[0];
		_string = _temp[1];
	}
	until (_temp[1] == "");
	return i;
}

/// @func bbmod_string_join_array(_separator, _array)
///
/// @desc Joins an array into a string, putting separator in between each
/// entry.
///
/// @param {String} _separator The string to put in between entries.
/// @param {Array} _array The array to join.
///
/// @return {String} The resulting string.
function bbmod_string_join_array(_separator, _array)
{
	var _string = "";
	var i = 0;
	repeat (array_length(_array) - 1)
	{
		_string += string(_array[i++]) + _separator;
	}
	_string += string(_array[i]);
	return _string;
}
