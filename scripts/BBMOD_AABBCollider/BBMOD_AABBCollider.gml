/// @func BBMOD_AABBCollider([_position[, _size]])
///
/// @extends BBMOD_Collider
///
/// @desc An axis-aligned bounding box (AABB) collider.
///
/// @param {Struct.BBMOD_Vec3} [_position] The position (center) of the AABB.
/// Defaults to `(0, 0, 0)`.
/// @param {Struct.BBMOD_Vec3} [_size] The size of the AABB on each
/// axis in both directions (e.g. `new BBMOD_Vec3(2)` would make a 4x4x4 box).
/// Defaults to `(0.5, 0.5, 0.5)`.
///
/// @see BBMOD_FrustumCollider
/// @see BBMOD_PlaneCollider
/// @see BBMOD_SphereCollider
function BBMOD_AABBCollider(
	_position=new BBMOD_Vec3(),
	_size=new BBMOD_Vec3(0.5)
) : BBMOD_Collider() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_Vec3} The center position of the AABB.
	Position = _position;

	/// @var {Struct.BBMOD_Vec3} The size of the AABB on each axis in both
	/// directions (e.g. `new BBMOD_Vec3(2)` would be a 4x4x4 box).
	Size = _size;

	/// @func FromMinMax(_min, _max)
	///
	/// @desc Initializes the AABB using its minimum and maximum coordinates.
	///
	/// @param {Struct.BBMOD_Vec3} _min The minimum coordinate of the AABB.
	/// @param {Struct.BBMOD_Vec3} _max The maximum coordinate of the AABB.
	///
	/// @return {Struct.BBMOD_AABBCollider} Returns `self`.
	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L37
	static FromMinMax = function (_min, _max) {
		gml_pragma("forceinline");
		Position = _min.Add(_max).Scale(0.5);
		Size = _max.Sub(_min).Scale(0.5);
		return self;
	};

	/// @func GetMin()
	///
	/// @desc Retrieves the minimum coordinate of the AABB.
	///
	/// @return {Struct.BBMOD_Vec3} The minimum coordinate.
	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L24
	static GetMin = function () {
		gml_pragma("forceinline");
		var _p1 = Position.Add(Size);
		var _p2 = Position.Sub(Size);
		return _p1.Minimize(_p2);
	};

	/// @func GetMax()
	///
	/// @desc Retrieves the maximum coordinate of the AABB.
	///
	/// @return {Struct.BBMOD_Vec3} The maximum coordinate.
	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L30
	static GetMax = function () {
		gml_pragma("forceinline");
		var _p1 = Position.Add(Size);
		var _p2 = Position.Sub(Size);
		return _p1.Maximize(_p2);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L149
	static GetClosestPoint = function (_point) {
		gml_pragma("forceinline");
		return _point.Clamp(GetMin(), GetMax());
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L340
	static TestAABB = function (_aabb) {
		gml_pragma("forceinline");
		var _aMin = GetMin();
		var _aMax = GetMax();
		var _bMin = _aabb.GetMin();
		var _bMax = _aabb.GetMax();
		return ((_aMin.X <= _bMax.X && _aMax.X >= _bMin.X)
			&& (_aMin.Y <= _bMax.Y && _aMax.Y >= _bMin.Y)
			&& (_aMin.Z <= _bMax.Z && _aMax.Z >= _bMin.Z));
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L482
	static TestPlane = function (_plane) {
		gml_pragma("forceinline");
		var _pLen = (Size.X * abs(_plane.Normal.X)
			+ Size.Y * abs(_plane.Normal.Y)
			+ Size.Z * abs(_plane.Normal.Z));
		var _dist = _plane.Normal.Dot(Position) - _plane.Distance;
		return (abs(_dist) <= _pLen);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L108
	static TestPoint = function (_point) {
		gml_pragma("forceinline");
		var _min = GetMin();
		var _max = GetMax();
		if (_point.X < _min.X || _point.Y < _min.Y || _point.Z < _min.Z)
		{
			return false;
		}
		if (_point.X > _max.X || _point.Y > _max.Y || _point.Z > _max.Z)
		{
			return false;
		}
		return true;
	};

	static TestSphere = function (_sphere) {
		gml_pragma("forceinline");
		return _sphere.TestAABB(self);
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L707
	static Raycast = function (_ray, _result=undefined) {
		if (_result != undefined)
		{
			_result.Reset();
		}

		var _min = GetMin();
		var _max = GetMax();

		var _t1 = (_min.X - _ray.Origin.X)
			/ (bbmod_cmp(_ray.Direction.X, 0.0) ? 0.00001 : _ray.Direction.X);
		var _t2 = (_max.X - _ray.Origin.X)
			/ (bbmod_cmp(_ray.Direction.X, 0.0) ? 0.00001 : _ray.Direction.X);
		var _t3 = (_min.Y - _ray.Origin.Y)
			/ (bbmod_cmp(_ray.Direction.Y, 0.0) ? 0.00001 : _ray.Direction.Y);
		var _t4 = (_max.Y - _ray.Origin.Y)
			/ (bbmod_cmp(_ray.Direction.Y, 0.0) ? 0.00001 : _ray.Direction.Y);
		var _t5 = (_min.Z - _ray.Origin.Z)
			/ (bbmod_cmp(_ray.Direction.Z, 0.0) ? 0.00001 : _ray.Direction.Z);
		var _t6 = (_max.Z - _ray.Origin.Z)
			/ (bbmod_cmp(_ray.Direction.Z, 0.0) ? 0.00001 : _ray.Direction.Z);

		var _tmin = max(max(min(_t1, _t2), min(_t3, _t4)), min(_t5, _t6));
		var _tmax = min(min(max(_t1, _t2), max(_t3, _t4)), max(_t5, _t6));

		if (_tmax < 0.0)
		{
			return false;
		}

		if (_tmin > _tmax)
		{
			return false;
		}

		if (_result != undefined)
		{
			var _tResult = (_tmin < 0.0) ? _tmax : _tmin;

			_result.Distance = _tResult;
			_result.Point = _ray.Origin.Add(_ray.Direction.Scale(_tResult));

			for (var i = 0; i < 6; ++i)
			{
				var _ti;

				switch (i)
				{
				case 0:
					_ti = _t1;
					break;

				case 1:
					_ti = _t2;
					break;

				case 2:
					_ti = _t3;
					break;

				case 3:
					_ti = _t4;
					break;

				case 4:
					_ti = _t5;
					break;

				case 5:
					_ti = _t6;
					break;
				}

				if (bbmod_cmp(_tResult, _ti))
				{
					switch (i)
					{
					case 0:
						_result.Normal = new BBMOD_Vec3(-1.0, 0.0, 0.0);
						break;

					case 1:
						_result.Normal = new BBMOD_Vec3(1.0, 0.0, 0.0);
						break;

					case 2:
						_result.Normal = new BBMOD_Vec3(0.0, -1.0, 0.0);
						break;

					case 3:
						_result.Normal = new BBMOD_Vec3(0.0, 1.0, 0.0);
						break;

					case 4:
						_result.Normal = new BBMOD_Vec3(0.0, 0.0, -1.0);
						break;

					case 5:
						_result.Normal = new BBMOD_Vec3(0.0, 0.0, 1.0);
						break;
					}
				}
			}
		}

		return true;
	};

	static DrawDebug = function (_color=c_white, _alpha=1.0) {
		var _vbuffer = global.__bbmodVBufferDebug;

		var _x1 = Position.X - Size.X;
		var _x2 = Position.X + Size.X;
		var _y1 = Position.Y - Size.Y;
		var _y2 = Position.Y + Size.Y;
		var _z1 = Position.Z - Size.Z;
		var _z2 = Position.Z + Size.Z;

		vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

		// Bottom
		// 1--2
		// |  |
		// 4--3
		vertex_position_3d(_vbuffer, _x1, _y1, _z1); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x2, _y1, _z1); vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, _x2, _y1, _z1); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x2, _y2, _z1); vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, _x2, _y2, _z1); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x1, _y2, _z1); vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, _x1, _y2, _z1); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x1, _y1, _z1); vertex_color(_vbuffer, _color, _alpha);

		// Top
		// 1--2
		// |  |
		// 4--3
		vertex_position_3d(_vbuffer, _x1, _y1, _z2); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x2, _y1, _z2); vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, _x2, _y1, _z2); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x2, _y2, _z2); vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, _x2, _y2, _z2); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x1, _y2, _z2); vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, _x1, _y2, _z2); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x1, _y1, _z2); vertex_color(_vbuffer, _color, _alpha);

		// Sides
		// 1--2
		// |  |
		// 4--3
		vertex_position_3d(_vbuffer, _x1, _y1, _z1); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x1, _y1, _z2); vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, _x2, _y1, _z1); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x2, _y1, _z2); vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, _x2, _y2, _z1); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x2, _y2, _z2); vertex_color(_vbuffer, _color, _alpha);

		vertex_position_3d(_vbuffer, _x1, _y2, _z1); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _x1, _y2, _z2); vertex_color(_vbuffer, _color, _alpha);

		vertex_end(_vbuffer);

		vertex_submit(_vbuffer, pr_linelist, -1);

		return self;
	};
}
