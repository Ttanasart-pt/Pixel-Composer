/// @func BBMOD_Resource()
///
/// @extends BBMOD_Class
///
/// @desc Base struct for all BBMOD resources.
function BBMOD_Resource()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

	/// @var {Bool} If `false` then the resource has not been loaded yet.
	/// @readonly
	IsLoaded = false;

	/// @var {String} The path to the file from which was the resource
	/// loaded, or `undefined` if the resource does not come from a file.
	/// @readonly
	Path = undefined;

	/// @var {Bool] If `true` then the resource is persistent and it is not
	/// destroyed when method `free` is used. Default value is `false`.
	/// @see BBMOD_Resource.free
	/// @see BBMOD_ResourceManager.free
	Persistent = false;

	/// @var {Struct.BBMOD_ResourceManager} The resource manager that loaded
	/// the resource.
	/// @private
	__manager = undefined;

	/// @var {Real} Number of resource "lives". If it reaches 0, the resource is
	/// destroyed.
	/// @private
	__counter = 1;

	/// @func from_buffer(_buffer)
	///
	/// @desc Loads the resource from a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to load the resource from.
	///
	/// @return {Struct.BBMOD_Resource} Returns `self`.
	///
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static from_buffer = function (_buffer) {
		throw new BBMOD_NotImplementedException();
		// When implementing this method, do not forget to set IsLoaded to true!
		//return self;
	};

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the resource to a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write the resource to.
	///
	/// @return {Struct.BBMOD_Resource} Returns `self`.
	///
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static to_buffer = function (_buffer) {
		throw new BBMOD_NotImplementedException();
		// When implementing this method, do not forget to set IsLoaded to true!
		//return self;
	};

	/// @func check_file(_file[, _sha1[, _callback]])
	///
	/// @param {String} _file
	/// @param {String} [_sha1]
	/// @param {Function} [_callback]
	///
	/// @return {Bool}
	///
	/// @throws {BBMOD_Exception}
	///
	/// @private
	static check_file = function (_file, _sha1=undefined, _callback=undefined) {
		var _err = undefined;

		if (!file_exists(_file))
		{
			_err = new BBMOD_Exception("File " + _file + " does not exist!");
		}
		else if (_sha1 != undefined)
		{
			if (sha1_file(_file) != _sha1)
			{
				_err = new BBMOD_Exception("SHA1 does not match!");
			}
		}

		if (_err != undefined)
		{
			if (_callback != undefined)
			{
				_callback(_err);
				return false;
			}
			else
			{
				throw _err;
			}
		}

		return true;
	};

	/// @func from_file(_file[, _sha1])
	///
	/// @desc Loads the resource from a file.
	///
	/// @param {String} _file The path to the file.
	/// @param {String} [_sha1] Expected SHA1 of the file. If the actual one
	/// does not match with this, then the resource will not be loaded. Use
	/// `undefined` if you do not want to check the SHA1 of the file.
	///
	/// @return {Struct.BBMOD_Resource} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If loading fails.
	static from_file = function (_file, _sha1=undefined) {
		Path = _file;

		check_file(_file, _sha1);

		var _buffer = buffer_load(_file);
		buffer_seek(_buffer, buffer_seek_start, 0);

		try
		{
			from_buffer(_buffer);
			buffer_delete(_buffer);
		}
		catch (_e)
		{
			buffer_delete(_buffer);
			throw _e;
		}

		return self;
	};

	/// @func to_file(_file)
	///
	/// @desc Writes a resource to a file.
	///
	/// @param {String} _file The path to the file.
	///
	/// @return {Struct.BBMOD_Resource} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If saving fails.
	static to_file = function (_file) {
		var _buffer = buffer_create(1, buffer_grow, 1);

		var _dirname = filename_dir(_file);
		if (!directory_exists(_dirname))
		{
			directory_create(_dirname);
		}

		try
		{
			to_buffer(_buffer);
			buffer_save(_buffer, _file);
			buffer_delete(_buffer);
		}
		catch (_e)
		{
			buffer_delete(_buffer);
			throw _e;
		}

		return self;
	};

	/// @func from_file_async(_file[, _sha1[, _callback]])
	///
	/// @desc Asynchronnously loads the resource from a file.
	///
	/// @param {String} _file The path to the file.
	/// @param {String} [_sha1] Expected SHA1 of the file. If the actual
	/// one does not match with this, then the resource will not be loaded. Use
	/// `undefined` if you do not want to check the SHA1 of the file.
	/// @param {Function} [_callback] The function to execute when the
	/// resource is loaded or if an error occurs or. It must take the error as the
	/// first argument and the resource as the second argument. If no error occurs,
	/// then `undefined` is passed. Defaults to `undefined`.
	///
	/// @return {Struct.BBMOD_Resource} Returns `self`.
	///
	/// @note Do not forget to call {@link bbmod_async_save_load_update} and
	/// {@link bbmod_async_image_loaded_update} in appropriate events when using
	/// asynchronnous loading! You can also use {@link BBMOD_ResourceManager} for
	/// unified asynchronnous loading of resources.
	static from_file_async = function (_file, _sha1=undefined, _callback=undefined) {
		Path = _file;

		if (!check_file(_file, _sha1, _callback ?? bbmod_empty_callback))
		{
			return self;
		}

		var _resource = self;
		var _struct = {
			Resource: _resource,
			Callback: _callback,
		};

		bbmod_buffer_load_async(_file, method(_struct, function (_err, _buffer) {
			var _callback = Callback;
			if (_err)
			{
				if (_callback != undefined)
				{
					_callback(_err, Resource);
				}
				return;
			}

			try
			{
				Resource.from_buffer(_buffer);
			}
			catch (_err2)
			{
				if (_callback != undefined)
				{
					_callback(_err2, Resource);
				}
				return;
			}

			if (_callback != undefined)
			{
				_callback(undefined, Resource);
			}
		}));

		return self;
	};

	/// @func ref()
	///
	/// @desc Retrieves a reference to the resource.
	///
	/// @return {Struct.BBMOD_Resource} Returns `self`.
	static ref = function () {
		gml_pragma("forceinline");
		if (!Persistent)
		{
			++__counter;
		}
		return self;
	};

	/// @func free()
	///
	/// @desc Releases a reference to the resource.
	///
	/// @return {Bool} Returns `true` if there are no other references to the
	/// resource and the resource is destroyed.
	///
	/// @note This does not destroy the resource if it is persistent!
	///
	/// @see BBMOD_Resource.Persistent
	static free = function () {
		gml_pragma("forceinline");
		if (!Persistent && --__counter == 0)
		{
			destroy();
			return true;
		}
		return false;
	};

	static destroy = function () {
		Class_destroy();
		if (__manager != undefined)
		{
			ds_map_delete(__manager.__resources, Path);
			__manager = undefined;
		}
		return undefined;
	};
}
