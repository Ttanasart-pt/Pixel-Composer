/// @func BBMOD_PointLight([_color[, _position[, _range]]])
///
/// @extends BBMOD_PunctualLight
///
/// @desc A point light.
///
/// @param {Struct.BBMOD_Color} [_color] The light's color. Defaults
/// to {@link BBMOD_C_WHITE}.
/// @param {Struct.BBMOD_Vec3} [_position] The light's position.
/// Defaults to `(0, 0, 0)`.
/// @param {Real} [_range] The light's range. Defaults to 1.
function BBMOD_PointLight(_color=BBMOD_C_WHITE, _position=undefined, _range=1.0)
	: BBMOD_PunctualLight(_color, _position, _range) constructor
{
	BBMOD_CLASS_GENERATED_BODY;
}

/// @func bbmod_light_point_add(_light)
///
/// @desc Adds a point light to be sent to shaders.
///
/// @param {Struct.BBMOD_PointLight} _light The point light.
///
/// @deprecated Please use {@link bbmod_light_punctual_add} instead.
function bbmod_light_point_add(_light)
{
	gml_pragma("forceinline");
	bbmod_light_punctual_add(_light);
}

/// @func bbmod_light_point_count()
///
/// @desc Retrieves number of point lights added to be sent to shaders.
///
/// @return {Real} The number of point lights added to be sent to shaders.
///
/// @deprecated Please use {@link bbmod_light_punctual_count} instead.
function bbmod_light_point_count()
{
	gml_pragma("forceinline");
	return bbmod_light_punctual_count();
}

/// @func bbmod_light_point_get(_index)
///
/// @desc Retrieves a point light at given index.
///
/// @param {Real} _index The index of the point light.
///
/// @return {Struct.BBMOD_PointLight} The point light.
///
/// @deprecated Please use {@link bbmod_light_punctual_get} instead.
function bbmod_light_point_get(_index)
{
	gml_pragma("forceinline");
	return bbmod_light_punctual_get(_index);
}

/// @func bbmod_light_point_remove(_light)
///
/// @desc Removes a point light so it is not sent to shaders anymore.
///
/// @param {Struct.BBMOD_PointLight} _light The point light to remove.
///
/// @return {Bool} Returns `true` if the point light was removed or `false` if
/// the light was not found.
///
/// @deprecated Please use {@link bbmod_light_punctual_remove} instead.
function bbmod_light_point_remove(_light)
{
	gml_pragma("forceinline");
	return bbmod_light_punctual_remove(_light);
}

/// @func bbmod_light_point_remove_index(_index)
///
/// @desc Removes a point light so it is not sent to shaders anymore.
///
/// @param {Real} _index The index to remove the point light at.
///
/// @return {Bool} Always returns `true`.
///
/// @deprecated Please use {@link bbmod_light_punctual_remove_index} instead.
function bbmod_light_point_remove_index(_index)
{
	gml_pragma("forceinline");
	return bbmod_light_punctual_remove_index(_index);
}

/// @func bbmod_light_point_clear()
///
/// @desc Removes all point lights sent to shaders.
///
/// @deprecated Please use {@link bbmod_light_punctual_clear} instead.
function bbmod_light_point_clear()
{
	gml_pragma("forceinline");
	bbmod_light_punctual_clear();
}
