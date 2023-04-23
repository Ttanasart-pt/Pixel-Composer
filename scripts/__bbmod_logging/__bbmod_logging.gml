/// @enum Enumeration of log levels.
/// @private
enum __BBMOD_ELogLevel
{
	/// @member Debug messages. Equals 0.
	Debug,
	/// @member Info messages. Equals 1. This is the default log level.
	Info,
	/// @member Warnings. Equals 2.
	Warning,
	/// @member Error messages. Equals 3.
	Error,
	/// @member Log messages disabled. Equals 4.
	Disabled,
};

/// @func __bbmod_log_level_to_string(_logLevel)
///
/// @param {Real} _logLevel Use values from {@link __BBMOD_ELogLevel}.
///
/// @return {String}
///
/// @private
function __bbmod_log_level_to_string(_logLevel)
{
	gml_pragma("forceinline");
	static _names = [
		"DEBUG",
		"INFO",
		"WARNING",
		"ERROR",
	];
	return _names[_logLevel];
}

/// @func __bbmod_log(_level, _format[, _values])
///
/// @param {Real} _level Use values from {@link __BBMOD_ELogLevel}.
/// @param {String} _format
/// @param {Array} [_values]
///
/// @private
function __bbmod_log(_level, _format, _values=[])
{
	gml_pragma("forceinline");
	show_debug_message_ext(
		"[" + date_time_string(date_current_datetime()) + "]"
			+ "[" + __bbmod_log_level_to_string(_level) + "]"
			+ " BBMOD: " + _format,
		_values);
}

/// @func __bbmod_debug(_format[, _values])
///
/// @param {String} _format
/// @param {Array} [_values]
///
/// @private
function __bbmod_debug(_format, _values=[])
{
	gml_pragma("forceinline");
	__bbmod_log(__BBMOD_ELogLevel.Debug, _format, _values);
}

/// @func __bbmod_info(_format[, _values])
///
/// @param {String} _format
/// @param {Array} [_values]
///
/// @private
function __bbmod_info(_format, _values=[])
{
	gml_pragma("forceinline");
	__bbmod_log(__BBMOD_ELogLevel.Info, _format, _values);
}

/// @func __bbmod_warning(_format[, _values])
///
/// @param {String} _format
/// @param {Array} [_values]
///
/// @private
function __bbmod_warning(_format, _values=[])
{
	gml_pragma("forceinline");
	__bbmod_log(__BBMOD_ELogLevel.Warning, _format, _values);
}

/// @func __bbmod_error(_format[, _values])
///
/// @param {String} _format
/// @param {Array} [_values]
///
/// @private
function __bbmod_error(_format, _values=[])
{
	gml_pragma("forceinline");
	__bbmod_log(__BBMOD_ELogLevel.Error, _format, _values);
}
