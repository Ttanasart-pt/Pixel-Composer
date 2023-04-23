/// @func bbmod_json_load(_file)
///
/// @desc Loads a JSON file.
///
/// @param {String} _file The path to the file.
///
/// @return {Struct, Array} The loaded JSON.
function bbmod_json_load(_file)
{
	var _jsonFile = file_text_open_read(_file);
	var _jsonString = "";
	while (!file_text_eof(_jsonFile))
	{
		_jsonString += file_text_read_string(_jsonFile) + "\n";
		file_text_readln(_jsonFile);
	}
	file_text_close(_jsonFile);
	return json_parse(_jsonString);
}
