/// @macro {String} Directory separator.
/// @private
#macro __BBMOD_PATH_SEPARATOR ((os_type == os_windows) ? "\\" : "/")

/// @macro {String} The current directory in relative paths.
/// @private
#macro __BBMOD_PATH_CURRENT "."

/// @macro {String} The parent directory in relative paths.
/// @private
#macro __BBMOD_PATH_PARENT ".."

/// @func bbmod_path_normalize(_path)
///
/// @desc Normalizes path for the current platform.
///
/// @param {String} _path The path to normalize.
///
/// @return {String} The normalized path.
function bbmod_path_normalize(_path)
{
	gml_pragma("forceinline");
	return string_replace_all(_path,
		(os_type == os_windows) ? "/" : "\\", __BBMOD_PATH_SEPARATOR);
}

/// @func bbmod_path_is_relative(_path)
///
/// @desc Checks if a path is relative.
///
/// @param {String} _path The path to check.
///
/// @return {Bool} Returns `true` if the path is relative.
function bbmod_path_is_relative(_path)
{
	gml_pragma("forceinline");
	_path = bbmod_path_normalize(_path);
	return (bbmod_string_starts_with(_path, __BBMOD_PATH_CURRENT + __BBMOD_PATH_SEPARATOR)
		|| bbmod_string_starts_with(_path, __BBMOD_PATH_PARENT + __BBMOD_PATH_SEPARATOR));
}


/// @func bbmod_path_is_absolute(_path)
///
/// @desc Checks if a path is absolute.
///
/// @param {String} _path The path to check.
///
/// @return {Bool} Returns `true` if the path is absolute.
function bbmod_path_is_absolute(_path)
{
	gml_pragma("forceinline");
	return !bbmod_path_is_relative(_path);
}

/// @func bbmod_path_get_relative(_path[, _start])
///
/// @desc Retrieves a relative version of a path.
///
/// @param {String} _path The path to get a relative version of. Must be
/// absolute!
/// @param {String} [_start] Which path should it be relative to. Must be
/// absolute! Defaults to the working directory.
///
/// @return {String} The relative path.
///
/// @note If given paths are not on the same drive then an unmodified path is
/// returned!
function bbmod_path_get_relative(_path, _start=working_directory)
{
	_path = bbmod_path_normalize(_path);

	var _pathExploded = [];
	var _pathExplodedSize = bbmod_string_explode(_path, __BBMOD_PATH_SEPARATOR, _pathExploded);

	var _startExploded = [];
	var _startExplodedSize = bbmod_string_explode(_start, __BBMOD_PATH_SEPARATOR, _startExploded);

	if (os_type == os_windows
		&& _pathExploded[0] != _startExploded[0])
	{
		return _path;
	}

	var _pathRelative = [];
	var _levelStart = 0;
	repeat (min(_startExplodedSize, _pathExplodedSize))
	{
		if (_startExploded[_levelStart] != _pathExploded[_levelStart])
		{
			break;
		}
		++_levelStart;
	}

	var _levelEnd = _pathExplodedSize;
	var _levelCurrent = _startExplodedSize;

	if (_levelCurrent > _levelStart)
	{
		while (_levelCurrent > _levelStart)
		{
			array_push(_pathRelative, __BBMOD_PATH_PARENT);
			--_levelCurrent;
		}
	}
	else
	{
		array_push(_pathRelative, __BBMOD_PATH_CURRENT);
	}

	while (_levelCurrent < _levelEnd)
	{
		array_push(_pathRelative, _pathExploded[_levelCurrent++]);
	}

	return bbmod_string_join_array(__BBMOD_PATH_SEPARATOR, _pathRelative);
}

/// @func bbmod_path_get_absolute(_path[, _start])
///
/// @desc Retrieves an absolute version of a path.
///
/// @param {String} _path The relative path to turn into absolute.
/// @param {String} [_start] Which path is it relative to. Must be absolute!
/// Defaults to the working directory.
///
/// @return {String} The absolute path.
///
/// @note If the path is already absolute then an unmodified path is returned.
function bbmod_path_get_absolute(_path, _start=working_directory)
{
	_path = bbmod_path_normalize(_path);

	if (bbmod_path_is_absolute(_path))
	{
		return _path;
	}

	var _pathExploded = [];
	var _pathExplodedSize = bbmod_string_explode(_path, __BBMOD_PATH_SEPARATOR, _pathExploded);

	var _startExploded = [];
	var _startExplodedSize = bbmod_string_explode(_start, __BBMOD_PATH_SEPARATOR, _startExploded);

	var _pathRelative = [];
	array_copy(_pathRelative, 0, _startExploded, 0, _startExplodedSize);

	var i = _startExplodedSize - 1;
	var j = 0;

	repeat (_pathExplodedSize)
	{
		var _str = _pathExploded[j++];

		switch (_str)
		{
		case __BBMOD_PATH_CURRENT:
			break;

		case __BBMOD_PATH_PARENT:
			array_delete(_pathRelative, i--, 1);
			break;

		default:
			array_push(_pathRelative, _str);
			break;
		}
	}

	return bbmod_string_join_array(__BBMOD_PATH_SEPARATOR, _pathRelative);
}
