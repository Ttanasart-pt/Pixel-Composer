/// @var {Array<Struct.BBMOD_PunctualLight>}
/// @private
global.__bbmodPunctualLights = [];

/// @func BBMOD_PunctualLight([_color[, _position[, _range]]])
///
/// @extends BBMOD_Light
///
/// @desc Base struct for punctual lights.
///
/// @param {Struct.BBMOD_Color} [_color] The light's color. Defaults
/// to {@link BBMOD_C_WHITE}.
/// @param {Struct.BBMOD_Vec3} [_position] The light's position.
/// Defaults to `(0, 0, 0)`.
/// @param {Real} [_range] The light's range. Defaults to 1.
///
/// @see BBMOD_PointLight
/// @see BBMOD_SpotLight
function BBMOD_PunctualLight(_color=BBMOD_C_WHITE, _position=undefined, _range=1.0)
	: BBMOD_Light() constructor
{
	BBMOD_CLASS_GENERATED_BODY;
	
	/// @var {Struct.BBMOD_Color} The color of the light. Default value is
	/// {@link BBMOD_C_WHITE}.
	Color = _color;

	if (_position != undefined)
	{
		Position = _position;
	}

	/// @var {Real} The range of the light.
	Range = _range;
}

/// @func bbmod_light_punctual_add(_light)
///
/// @desc Adds a punctual light to be sent to shaders.
///
/// @param {Struct.BBMOD_PunctualLight} _light The punctual light.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_count
/// @see bbmod_light_punctual_get
/// @see bbmod_light_punctual_remove
/// @see bbmod_light_punctual_remove_index
/// @see bbmod_light_punctual_clear
/// @see BBMOD_PunctualLight
function bbmod_light_punctual_add(_light)
{
	gml_pragma("forceinline");
	array_push(global.__bbmodPunctualLights, _light);
}

/// @func bbmod_light_punctual_count()
///
/// @desc Retrieves number of punctual lights added to be sent to shaders.
///
/// @return {Real} The number of punctual lights added to be sent to shaders.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_get
/// @see bbmod_light_punctual_remove
/// @see bbmod_light_punctual_remove_index
/// @see bbmod_light_punctual_clear
/// @see BBMOD_PunctualLight
function bbmod_light_punctual_count()
{
	gml_pragma("forceinline");
	return array_length(global.__bbmodPunctualLights);
}

/// @func bbmod_light_punctual_get(_index)
///
/// @desc Retrieves a punctual light at given index.
///
/// @param {Real} _index The index of the punctual light.
///
/// @return {Struct.BBMOD_PunctualLight} The punctual light.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_count
/// @see bbmod_light_punctual_remove
/// @see bbmod_light_punctual_remove_index
/// @see bbmod_light_punctual_clear
/// @see BBMOD_PunctualLight
function bbmod_light_punctual_get(_index)
{
	gml_pragma("forceinline");
	return global.__bbmodPunctualLights[_index];
}

/// @func bbmod_light_punctual_remove(_light)
///
/// @desc Removes a punctual light so it is not sent to shaders anymore.
///
/// @param {Struct.BBMOD_PunctualLight} _light The punctual light to remove.
///
/// @return {Bool} Returns `true` if the punctual light was removed or `false` if
/// the light was not found.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_count
/// @see bbmod_light_punctual_get
/// @see bbmod_light_punctual_remove_index
/// @see bbmod_light_punctual_clear
/// @see BBMOD_PunctualLight
function bbmod_light_punctual_remove(_light)
{
	gml_pragma("forceinline");
	var _punctualLights = global.__bbmodPunctualLights;
	var i = 0;
	repeat (array_length(_punctualLights))
	{
		if (_punctualLights[i] == _light)
		{
			array_delete(_punctualLights, i, 1);
			return true;
		}
		++i;
	}
	return false;
}

/// @func bbmod_light_punctual_remove_index(_index)
///
/// @desc Removes a punctual light so it is not sent to shaders anymore.
///
/// @param {Real} _index The index to remove the punctual light at.
///
/// @return {Bool} Always returns `true`.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_count
/// @see bbmod_light_punctual_get
/// @see bbmod_light_punctual_remove
/// @see bbmod_light_punctual_clear
/// @see BBMOD_PunctualLight
function bbmod_light_punctual_remove_index(_index)
{
	gml_pragma("forceinline");
	array_delete(global.__bbmodPunctualLights, _index, 1);
	return true;
}

/// @func bbmod_light_punctual_clear()
///
/// @desc Removes all punctual lights sent to shaders.
///
/// @see bbmod_light_punctual_add
/// @see bbmod_light_punctual_count
/// @see bbmod_light_punctual_get
/// @see bbmod_light_punctual_remove
/// @see bbmod_light_punctual_remove_index
/// @see BBMOD_PunctualLight
function bbmod_light_punctual_clear()
{
	gml_pragma("forceinline");
	global.__bbmodPunctualLights = [];
}
