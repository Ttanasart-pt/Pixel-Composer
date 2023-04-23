/// @func BBMOD_Collider()
///
/// @extends BBMOD_Class
///
/// @desc Base struct for colliders.
///
/// @see BBMOD_AABBCollider
/// @see BBMOD_FrustumCollider
/// @see BBMOD_PlaneCollider
/// @see BBMOD_SphereCollider
function BBMOD_Collider()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @func GetClosestPoint(_point)
	///
	/// @desc Retrieves a point on the surface of the collider that is closest
	/// to the point specified.
	///
	/// @param {Struct.BBMOD_Vec3} _point The point to get the closest point to.
	///
	/// @return {Struct.BBMOD_Vec3} A point on the surface of the collider that
	/// is closest to the point specified.
	///
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static GetClosestPoint = function (_point) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func TestAABB(_aabb)
	///
	/// @desc Tests whether the collider intersects with an AABB.
	///
	/// @param {Struct.BBMOD_AABBCollider} _aabb The AABB to check intersection
	/// with.
	///
	/// @return {Bool} Returns `true` if the colliders intersect.
	///
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static TestAABB = function (_aabb) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func TestFrustum(_frustum)
	///
	/// @desc Tests whether the collider intersects with a frustum.
	///
	/// @param {Struct.BBMOD_FrustumCollider} _frustum The frustum to check intersection
	/// with.
	///
	/// @return {Bool} Returns `true` if the colliders intersect.
	///
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static TestFrustum = function (_frustum) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func TestPlane(_plane)
	///
	/// @desc Tests whether the collider intersects with a plane.
	///
	/// @param {Struct.BBMOD_PlaneCollider} _plane The plane to check intersection
	/// with.
	///
	/// @return {Bool} Returns `true` if the colliders intersect.
	///
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static TestPlane = function (_plane) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func TestPoint(_point)
	///
	/// @desc Tests whether the collider intersects with a point.
	///
	/// @param {Struct.BBMOD_Vec3} _point The point to check intersection with.
	///
	/// @return {Bool} Returns `true` if the colliders intersect.
	///
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static TestPoint = function (_point) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func TestSphere(_sphere)
	///
	/// @desc Tests whether the collider intersects with a sphere.
	///
	/// @param {Struct.BBMOD_SphereCollider} _sphere The sphere to check
	/// intersection with.
	///
	/// @return {Bool} Returns `true` if the colliders intersect.
	///
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static TestSphere = function (_sphere) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func Raycast(_ray)
	///
	/// @desc Casts a ray against the collider.
	///
	/// @param {Struct.BBMOD_Ray} _ray The ray to cast.
	/// @param {Struct.BBMOD_RaycastResult} [_result] Where to store
	/// additional raycast info to or `undefined`.
	///
	/// @return {Bool} Returns `true` if the ray hits the collider.
	///
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	///
	/// @see BBMOD_RaycastResult
	/// @see BBMOD_Ray.Raycast
	static Raycast = function (_ray, _result=undefined) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func DrawDebug([_color])
	///
	/// @desc Draws a debug preview of the collider.
	///
	/// @param {Constant.Color} [_color] The preview color. Defaults to
	/// `c_white`.
	/// @param {Real} [_alpha] The preview alpha. Defaults to 1.
	///
	/// @return {Struct.BBMOD_Collider} Returns `self`.
	///
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static DrawDebug = function (_color=c_white, _alpha=1.0) {
		throw new BBMOD_NotImplementedException();
	};
}
