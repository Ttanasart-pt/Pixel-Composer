/// @var {Id.DsMap<Real, Function>}
/// @private
global.__bbmodAsyncCallback = ds_map_create();

/// @var {Id.DsMap<Real, Function>}
/// @private
global.__bbmodSpriteCallback = ds_map_create();

/// @func bbmod_empty_callback(_err[, _res])
///
/// @desc An empty callback function. Does nothing.
///
/// @param {Struct.BBMOD_Exception} _err An error or `undefined`.
/// @param {Any} [_res] A return value. Should be `undefined` if there is an
/// error.
function bbmod_empty_callback(_err, _res=undefined)
{
}

/// @func bbmod_buffer_load_async(_file, _callback)
///
/// @desc Asynchronnously loads a buffer from a file.
///
/// @param {String} _file The path to the file to load the buffer from.
/// @param {Function} _callback The function to execute when the buffer is
/// loaded or if an error occurs. It must take the error as the first argument
/// and the buffer as the second argument. If no error occurs, then `undefined`
/// is passed. If an error does occur, then buffer is `undefined`.
///
/// @example
/// ```gml
/// bbmod_buffer_load_async("buffer.bin", function (_error, _buffer) {
///     if (_error != undefined)
///     {
///         // Handle error here...
///         return;
///     }
///     // Use the loaded buffer here...
/// });
/// ```
///
/// @note You must call {@link bbmod_async_save_load_update} in an appropriate
/// event for this function to work!
function bbmod_buffer_load_async(_file, _callback)
{
	var _buffer = buffer_create(1, buffer_grow, 1);
	var _id = buffer_load_async(_buffer, _file, 0, -1);
	global.__bbmodAsyncCallback[? _id] = {
		Buffer: _buffer,
		Callback: _callback,
	};
}

/// @func bbmod_async_save_load_update(_asyncLoad)
///
/// @desc This function must be called in the "Async - Save/Load" event if
/// you use {@link bbmod_buffer_load_async} to asynchronnously load a buffer!
///
/// @param {Id.DsMap} _asyncLoad The `async_load` map.
///
/// @example
/// ```gml
/// /// @desc Create event
/// bbmod_buffer_load_async("buffer.bin", function (_err, _buffer) {
///     if (!_err)
///     {
///         // Use the loaded buffer here...
///     }
/// });
///
/// /// @desc Async - Save/Load event
/// bbmod_async_save_load_update(async_load);
/// ```
///
/// @see bbmod_buffer_load_async
function bbmod_async_save_load_update(_asyncLoad)
{
	var _map = global.__bbmodAsyncCallback;
	var _id = _asyncLoad[? "id"];
	var _data = _map[? _id];

	if (_asyncLoad[? "status"] == false)
	{
		buffer_delete(_data.Buffer);
		_data.Callback(new BBMOD_Exception("Async load failed!"));
	}
	else
	{
		var _buffer = _data.Buffer;
		buffer_seek(_buffer, buffer_seek_start, 0);
		_data.Callback(undefined, _buffer);
	}

	ds_map_delete(_map, _id);
}

/// @func bbmod_sprite_add_async(_file, _callback)
///
/// @desc Asynchronnously loads a sprite from a file.
/// 
/// @param {String} _file The path to the file to load the sprite from.
/// @param {Function} _callback The function to execute when the sprite is
/// loaded or if an error occurs. It must take the error as the first argument
/// and the sprite as the second argument. If no error occurs, then `undefined`
/// is passed. If an error does occur, then sprite is `undefined`.
///
/// @example
/// ```gml
/// bbmod_sprite_add_async("sprite.png", function (_error, _sprite) {
///     if (_error != undefined)
///     {
///         // Handle error here...
///         return;
///     }
///     // Use the loaded sprite here...
/// });
/// ```
///
/// @note You must call {@link bbmod_async_image_loaded_update} in an appropriate
/// event for this function to work!
function bbmod_sprite_add_async(_file, _callback)
{
	var _id = sprite_add(_file, 0, false, false, 0, 0);

	if (os_browser == browser_not_a_browser)
	{
		_callback(undefined, _id);
	}
	else
	{
		global.__bbmodSpriteCallback[? _id] = {
			Callback: _callback,
		};
	}
}

/// @func bbmod_async_image_loaded_update(_asyncLoad)
///
/// @desc This function must be called in the "Async - Image Loaded" event if
/// you use {@link bbmod_sprite_add_async} to asynchronnously load a sprite!
///
/// @param {Id.DsMap} _asyncLoad The `async_load` map.
///
/// @example
/// ```gml
/// /// @desc Create event
/// bbmod_sprite_add_async("sprite.png", function (_err, _sprite) {
///     if (!_err)
///     {
///         sprite_index = _sprite;
///     }
/// });
///
/// /// @desc Async - Image Loaded event
/// bbmod_async_image_loaded_update(async_load);
/// ```
///
/// @see bbmod_sprite_add_async
function bbmod_async_image_loaded_update(_asyncLoad)
{
	var _map = global.__bbmodSpriteCallback;
	var _id = async_load[? "id"];
	var _data = _map[? _id];

	if (async_load[? "status"] == false)
	{
		_data.Callback(new BBMOD_Exception("Async load failed!"));
	}
	else
	{
		_data.Callback(undefined, _id);
	}

	ds_map_delete(_map, _id);
}
