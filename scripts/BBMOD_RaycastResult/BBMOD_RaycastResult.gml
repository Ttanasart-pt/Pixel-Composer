/// @func BBMOD_RaycastResult()
///
/// @desc A structure for holding additional raycast data.
///
/// @see BBMOD_Collider.Raycast
/// @see BBMOD_Ray.Raycast
function BBMOD_RaycastResult() constructor
{
	/// @var {Real} The distance from the ray's origin at which it has hit
	/// the collider.
	Distance = 0.0;

	/// @var {Struct.BBMOD_Vec3} The point of collision in world-space or
	/// `undefined`.
	Point = undefined;

	/// @var {Struct.BBMOD_Vec3} The normal vector at the collision or
	/// `undefined`.
	Normal = undefined;

	/// @func Reset()
	///
	/// @desc Resets properties to their default values.
	///
	/// @return {Struct.BBMOD_RaycastResult} Returns `self`.
	static Reset = function () {
		gml_pragma("forceinline");
		Distance = 0.0;
		Point = undefined;
		Normal = undefined;
		return self;
	};
}
