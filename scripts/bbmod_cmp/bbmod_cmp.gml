/// @func bbmod_cmp(_a, _b)
///
/// @desc Checks whether two number are equal, taking into account
/// `math_get_epsilon`.
///
/// @param {Real} _a The first number.
/// @param {Real} _b The second number.
///
/// @return {Bool} Returns `true` if the two numbers are equal.
// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L6
function bbmod_cmp(_a, _b)
{
	gml_pragma("forceinline");
	return (abs(_a - _b) <= math_get_epsilon() * max(1.0, abs(_a), abs(_b)));
}
