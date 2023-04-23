/// @func BBMOD_PlaneCollider([_normal[, _distance]])
///
/// @extends BBMOD_Collider
///
/// @desc A plane collider.
///
/// @param {Struct.BBMOD_Vec3} [_normal] The plane's normal vector. Defaults to
/// {@link BBMOD_VEC3_UP}.
/// @param {Real} [_distance] The plane's distance from the world origin.
///
/// @see BBMOD_AABBCollider
/// @see BBMOD_FrustumCollider
/// @see BBMOD_SphereCollider
function BBMOD_PlaneCollider(_normal=undefined, _distance=0.0)
	: BBMOD_Collider() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_Vec3} The plane's normal vector.
	Normal = _normal ?? BBMOD_VEC3_UP;

	/// @var {Real} The plane's distance from the world origin.
	Distance = _distance;

	/// @func __getPointDistance(_point)
	///
	/// @param {Struct.BBMOD_Vec3} _point
	///
	/// @return {Real}
	///
	/// @private
	static __getPointDistance = function (_point) {
		gml_pragma("forceinline");
		return (_point.Dot(Normal) - Distance);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L188
	static GetClosestPoint = function (_point) {
		gml_pragma("forceinline");
		return _point.Sub(Normal.Scale(__getPointDistance(_point)));
	};

	static TestAABB = function (_aabb) {
		gml_pragma("forceinline");
		return _aabb.TestPlane(self);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L541
	static TestPlane = function (_plane) {
		gml_pragma("forceinline");
		var _d = Normal.Cross(_plane.Normal);
		return !bbmod_cmp(_d.Dot(_d), 0.0);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L101
	static TestPoint = function (_point) {
		gml_pragma("forceinline");
		return bbmod_cmp(__getPointDistance(_point), 0.0);
	};

	static TestSphere = function (_sphere) {
		gml_pragma("forceinline");
		return _sphere.TestPlane(self);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L769
	static Raycast = function (_ray, _result=undefined) {
		if (_result != undefined)
		{
			_result.Reset();
		}

		var _nd = _ray.Direction.Dot(Normal);
		var _pn = _ray.Origin.Dot(Normal);

		if (_nd >= 0.0)
		{
			return false;
		}

		var _t = (Distance - _pn) / _nd;

		if (_t >= 0.0)
		{
			if (_result != undefined)
			{
				_result.Distance = _t;
				_result.Point = _ray.Origin.Add(_ray.Direction.Scale(_t));
				_result.Normal = Normal.Normalize();
			}
			return true;
		}

		return false;
	};
}
