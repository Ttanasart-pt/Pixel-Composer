/// @func bbmod_lerp_delta_time(_from, _to, _factor, _deltaTime)
///
/// @desc Linearly interpolates two values, taking delta time into account.
///
/// @param {Real} _from The value to interpolate from.
/// @param {Real} _to The value to interpolate to.
/// @param {Real} _factor The interpolation factor.
/// @param {Real} _deltaTime The `delta_time`.
///
/// @return {Real} The resulting value.
function bbmod_lerp_delta_time(_from, _to, _factor, _deltaTime)
{
	INLINE
	return lerp(
		_from,
		_to,
		_factor * (_deltaTime / game_get_speed(gamespeed_microseconds)));
}
