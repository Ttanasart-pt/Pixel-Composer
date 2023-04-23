/// @var {Struct.BBMOD_Color}
/// @private
global.__bbmodFogColor = BBMOD_C_WHITE;

/// @var {Real}
/// @private
global.__bbmodFogIntensity = 0.0;

/// @var {Real}
/// @private
global.__bbmodFogStart = 0.0;

/// @var {Real}
/// @private
global.__bbmodFogEnd = 1.0;

/// @func bbmod_fog_set(_color, _intensity, _start, _end)
///
/// @desc Defines fog properties sent to shaders.
///
/// @param {Struct.BBMOD_Color} _color The color of the fog. The default fog
/// color is white.
/// @param {Real} _intensity The intensity of the fog. Use values in range 0..1.
/// The default fog intensity is 0 (no fog).
/// @param {Real} _start The distance from the camera where the fog starts at.
/// The default fog start is 0.
/// @param {Real} _end The distance from the camera where the fog has the
/// maximum intensity. The default fog end is 1.
///
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see BBMOD_Color
function bbmod_fog_set(_color, _intensity, _start, _end)
{
	gml_pragma("forceinline");
	global.__bbmodFogColor = _color;
	global.__bbmodFogIntensity = _intensity;
	global.__bbmodFogStart = _start;
	global.__bbmodFogEnd = _end;
}

/// @func bbmod_fog_get_color()
///
/// @desc Retrieves the color of the fog that is sent to shaders.
///
/// @return {Struct.BBMOD_Color} The color of the fog.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see BBMOD_Color
function bbmod_fog_get_color()
{
	gml_pragma("forceinline");
	return global.__bbmodFogColor;
}

/// @func bbmod_fog_set_color(_color)
///
/// @desc Defines the color of the fog that is sent to shaders.
///
/// @param {Struct.BBMOD_Color} _color The new fog color. The default fog color
/// is white.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
/// @see BBMOD_Color
function bbmod_fog_set_color(_color)
{
	gml_pragma("forceinline");
	global.__bbmodFogColor = _color;
}

/// @func bbmod_fog_get_intensity()
///
/// @desc Retrieves the fog intensity that is sent to shaders.
///
/// @return {Real} The fog intensity.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
function bbmod_fog_get_intensity()
{
	gml_pragma("forceinline");
	return global.__bbmodFogIntensity;
}

/// @func bbmod_fog_set_intensity(_intensity)
///
/// @desc Defines the fog intensity that is sent to shaders.
///
/// @param {Real} _intensity The new fog intensity. The default intensity of the
/// fog is 0 (no fog).
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
function bbmod_fog_set_intensity(_intensity)
{
	gml_pragma("forceinline");
	global.__bbmodFogIntensity = _intensity;
}

/// @func bbmod_fog_get_start()
///
/// @desc Retrieves the distance where the fog starts at, as it is defined to be
/// sent to shaders.
///
/// @return {Real} The distance where the fog starts at.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
function bbmod_fog_get_start()
{
	gml_pragma("forceinline");
	return global.__bbmodFogStart;
}

/// @func bbmod_fog_set_start(_start)
///
/// @desc Defines distance where the fog starts at - to be sent to shaders.
///
/// @param {Real} _start The new distance where the fog starts at. The default
/// value is 0.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_get_end
/// @see bbmod_fog_set_end
function bbmod_fog_set_start(_start)
{
	gml_pragma("forceinline");
	global.__bbmodFogStart = _start;
}

/// @func bbmod_fog_get_end()
///
/// @desc Retrieves the distance where the fog has the maximum intensity, as it
/// is defined to be sent to shaders.
///
/// @return {Real} The distance where the fog has the maximum intensity.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_set_end
function bbmod_fog_get_end()
{
	gml_pragma("forceinline");
	return global.__bbmodFogEnd;
}

/// @func bbmod_fog_set_end(_end)
///
/// @desc Defines the distance where the fog has the maximum intensity - to be
/// sent to shaders.
///
/// @param {Real} _end The distance where the fog has the maximum intensity.
///
/// @see bbmod_fog_set
/// @see bbmod_fog_get_color
/// @see bbmod_fog_set_color
/// @see bbmod_fog_get_intensity
/// @see bbmod_fog_set_intensity
/// @see bbmod_fog_get_start
/// @see bbmod_fog_set_start
/// @see bbmod_fog_get_end
function bbmod_fog_set_end(_end)
{
	gml_pragma("forceinline");
	global.__bbmodFogEnd = _end;
}
