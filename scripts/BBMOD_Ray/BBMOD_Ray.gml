/// @func BBMOD_Ray(_origin, _direction)
///
/// @desc A ray used to raycast colliders.
///
/// @param {Struct.BBMOD_Vec3} _origin The ray's origin.
/// @param {Struct.BBMOD_Vec3} _direction The ray's direction. Should be
/// normalized!
///
/// @see BBMOD_Collider.Raycast
function BBMOD_Ray(_origin, _direction) constructor
{
	/// @var {Struct.BBMOD_Vec3} The ray's origin.
	Origin = _origin;

	/// @var {Struct.BBMOD_Vec3} The ray's direction. Should be normalized!
	Direction = _direction;

	/// @func Raycast(_collider[, _result])
	///
	/// @desc Casts the ray against a collider.
	///
	/// @param {Struct.BBMOD_Collider} _collider The collider to cast the ray
	/// against.
	/// @param {Struct.BBMOD_RaycastResult} [_result] Where to store
	/// additional raycast info to or `undefined`.
	///
	/// @return {Bool} Returns `true` if the ray hits the collider.
	///
	/// @throws {BBMOD_NotImplementedException} If the collider does not
	/// implement method `Raycast`.
	///
	/// @note This is the same as calling `_collider.Raycast(_ray, _result)`!
	///
	/// @see BBMOD_RaycastResult
	/// @see BBMOD_Collider.Raycast
	static Raycast = function (_collider, _result=undefined) {
		gml_pragma("forceinline");
		return _collider.Raycast(self, _result);
	};

	/// @func DrawDebug([_length[, _color]])
	///
	/// @desc Draws a debug preview of the ray.
	///
	/// @param {Real} [_length] The length of the ray. Defaults to 9999.
	/// @param {Constant.Color} [_color] The debug color. Defaults to
	/// `c_white`.
	/// @param {Real} [_alpha] The debug alpha. Defaults to 1.
	///
	/// @return {Struct.BBMOD_Ray} Returns `self`.
	static DrawDebug = function (_length=9999.0, _color=c_white, _alpha=1.0) {
		var _vbuffer = global.__bbmodVBufferDebug;
		var _start = Origin;
		var _end = _start.Add(Direction.Normalize().Scale(_length));

		vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);
		vertex_position_3d(_vbuffer, _start.X, _start.Y, _start.Z); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer,   _end.X,   _end.Y,   _end.Z); vertex_color(_vbuffer, _color, _alpha);
		vertex_end(_vbuffer);
		vertex_submit(_vbuffer, pr_linelist, -1);

		return self;
	};
}
