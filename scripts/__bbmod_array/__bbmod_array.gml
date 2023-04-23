/// @func bbmod_array_clone(_array)
///
/// @desc Creates a shallow clone of an array.
///
/// @param {Array} _array The array to create a clone of.
///
/// @return {Array} The created clone.
function bbmod_array_clone(_array)
{
	gml_pragma("forceinline");
	var _arrayLength = array_length(_array);
	var _clone = array_create(_arrayLength);
	array_copy(_clone, 0, _array, 0, _arrayLength);
	return _clone;
}

/// @func bbmod_array_to_buffer(_buffer, _type)
///
/// @desc Writes an array into a buffer.
///
/// @param {Array} _array The array to write to the buffer.
/// @param {Id.Buffer} _buffer The buffer to write the data to.
/// @param {Constant.BufferDataType} _type The value type.
function bbmod_array_to_buffer(_array, _buffer, _type)
{
	var i = 0;
	repeat (array_length(_array))
	{
		buffer_write(_buffer, _type, _array[i++]);
	}
}

/// @func bbmod_array_from_buffer(_buffer, _type, _size)
///
/// @desc Creates an array with values from a buffer.
///
/// @param {Id.Buffer} _buffer The buffer to load the data from.
/// @param {Constant.BufferDataType} _type The value type.
/// @param {Real} _size The number of values to load.
///
/// @return {Array} The created array.
function bbmod_array_from_buffer(_buffer, _type, _size)
{
	var _array = array_create(_size, 0);
	var i = 0;
	repeat (_size)
	{
		_array[@ i++] = buffer_read(_buffer, _type);
	}
	return _array;
}
