/// @enum Enumeration of frustum planes.
enum BBMOD_EFrustumPlane
{
	/// @member The left plane.
	Left,
	/// @member The right plane.
	Right,
	/// @member The top plane.
	Top,
	/// @member The bottom plane.
	Bottom,
	/// @member The near plane.
	Near,
	/// @member The far plane.
	Far,
	/// @member Total number of frustum planes.
	SIZE
};

/// @func BBMOD_FrustumCollider()
///
/// @extends BBMOD_Collider
///
/// @desc A frustum collider.
///
/// @see BBMOD_AABBCollider
/// @see BBMOD_PlaneCollider
/// @see BBMOD_SphereCollider
function BBMOD_FrustumCollider()
	: BBMOD_Collider() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Array<Struct.BBMOD_PlaneCollider>}
	/// @see BBMOD_PlaneCollider
	/// @see BBMOD_EFrustumPlane
	Planes = [
		new BBMOD_PlaneCollider(),
		new BBMOD_PlaneCollider(),
		new BBMOD_PlaneCollider(),
		new BBMOD_PlaneCollider(),
		new BBMOD_PlaneCollider(),
		new BBMOD_PlaneCollider(),
	];

	/// @func FromViewProjectionMatrix(_vp)
	///
	/// @desc Initializes the frustum from a view-projection matrix.
	///
	/// @param {Array<Real>} _vp The view-projection matrix.
	///
	/// @return {Struct.BBMOD_FrustumCollider} Returns `self`.
	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Camera.cpp#L269
	static FromViewProjectionMatrix = function (_vp) {
		var _col1 = new BBMOD_Vec3(_vp[0], _vp[4], _vp[ 8]);
		var _col2 = new BBMOD_Vec3(_vp[1], _vp[5], _vp[ 9]);
		var _col3 = new BBMOD_Vec3(_vp[2], _vp[6], _vp[10]);
		var _col4 = new BBMOD_Vec3(_vp[3], _vp[7], _vp[11]);

		// Find plane magnitudes
		Planes[BBMOD_EFrustumPlane.Left  ].Normal = _col4.Add(_col1);
		Planes[BBMOD_EFrustumPlane.Right ].Normal = _col4.Sub(_col1);
		Planes[BBMOD_EFrustumPlane.Bottom].Normal = _col4.Add(_col2);
		Planes[BBMOD_EFrustumPlane.Top   ].Normal = _col4.Sub(_col2);
		Planes[BBMOD_EFrustumPlane.Near  ].Normal = /*_col4.Add(*/_col3/*)*/;
		Planes[BBMOD_EFrustumPlane.Far   ].Normal = _col4.Sub(_col3);

		// Find plane distances
		var _vp12 = _vp[12];
		var _vp13 = _vp[13];
		var _vp14 = _vp[14];
		var _vp15 = _vp[15];

		Planes[BBMOD_EFrustumPlane.Left  ].Distance = _vp15 + _vp12;
		Planes[BBMOD_EFrustumPlane.Right ].Distance = _vp15 - _vp12;
		Planes[BBMOD_EFrustumPlane.Bottom].Distance = _vp15 + _vp13;
		Planes[BBMOD_EFrustumPlane.Top   ].Distance = _vp15 - _vp13;
		Planes[BBMOD_EFrustumPlane.Near  ].Distance = /*_vp15 +*/ _vp14;
		Planes[BBMOD_EFrustumPlane.Far   ].Distance = _vp15 - _vp14;

		// Normalize all 6 planes
		for (var i = 0; i < BBMOD_EFrustumPlane.SIZE; ++i)
		{
			with (Planes[i])
			{
				var _n = 1.0 / Normal.Length();
				Normal = Normal.Scale(_n);
				Distance *= _n;
			}
		}

		return self;
	};

	/// @func FromCamera(_camera)
	///
	/// @desc Initializes the frustum using a camera's view-projection matrix.
	///
	/// @param {Struct.BBMOD_BaseCamera} _camera The camera.
	///
	/// @return {Struct.BBMOD_FrustumCollider} Returns `self`.
	///
	/// @see BBMOD_BaseCamera.ViewProjectionMatrix
	static FromCamera = function (_camera) {
		gml_pragma("forceinline");
		FromViewProjectionMatrix(_camera.ViewProjectionMatrix);
		return self;
	};

	/// @func __intersectPlanes(_p1, _p2, _p3)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_PlaneCollider} _p1
	/// @param {Struct.BBMOD_PlaneCollider} _p2
	/// @param {Struct.BBMOD_PlaneCollider} _p3
	///
	/// @returns {Struct.BBMOD_Vec3,Undefined}
	///
	/// @private
	// Source: https://donw.io/post/frustum-point-extraction/
	static __intersectPlanes = function (_p0, _p1, _p2) {
		var bxc = _p1.Normal.Cross(_p2.Normal);
		var cxa = _p2.Normal.Cross(_p0.Normal);
		var axb = _p0.Normal.Cross(_p1.Normal);
		var r = bxc.Scale(-_p0.Distance).Sub(cxa.Scale(_p1.Distance)).Sub(axb.Scale(_p2.Distance));
		return r.Scale(1.0 / _p0.Normal.Dot(bxc));
	};

	/// @func GetCorners()
	///
	/// @desc Retrieves an array of frustum corners.
	///
	/// @return {Array<Struct.BBMOD_Vec3>} The array of frustum corners in order
	/// `nearTopLeft`, `nearTopRight`, `nearBottomLeft`, `nearBottomRight`,
	/// `farTopLeft`, `farTopRight`, `farBottomLeft` and `farBottomRight`.
	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L1850
	static GetCorners = function () {
		var _near   = Planes[BBMOD_EFrustumPlane.Near];
		var _far    = Planes[BBMOD_EFrustumPlane.Far];
		var _top    = Planes[BBMOD_EFrustumPlane.Top];
		var _bottom = Planes[BBMOD_EFrustumPlane.Bottom];
		var _left   = Planes[BBMOD_EFrustumPlane.Left];
		var _right  = Planes[BBMOD_EFrustumPlane.Right];

		return [
			__intersectPlanes(_near, _top,    _left),
			__intersectPlanes(_near, _top,    _right),
			__intersectPlanes(_near, _bottom, _left),
			__intersectPlanes(_near, _bottom, _right),
			__intersectPlanes(_far,  _top,    _left),
			__intersectPlanes(_far,  _top,    _right),
			__intersectPlanes(_far,  _bottom, _left),
			__intersectPlanes(_far,  _bottom, _right),
		];
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L1861
	static TestPoint = function (_point) {
		for (var i = 0; i < BBMOD_EFrustumPlane.SIZE; ++i)
		{
			var _plane = Planes[i];
			if ((_point.Dot(_plane.Normal) + _plane.Distance) < 0.0)
			{
				return false;
			}
		}
		return true;
	};

	// Source: https://github.com/gszauer/GamePhysicsCookbook/blob/a0b8ee0c39fed6d4b90bb6d2195004dfcf5a1115/Code/Geometry3D.cpp#L1874
	static TestSphere = function (_sphere) {
		for (var i = 0; i < BBMOD_EFrustumPlane.SIZE; ++i)
		{
			var _plane = Planes[i];
			if ((_sphere.Position.Dot(_plane.Normal) + _plane.Distance) < -_sphere.Radius)
			{
				return false;
			}
		}
		return true;
	};

	static DrawDebug = function (_color=c_white, _alpha=1.0) {
		var _vbuffer = global.__bbmodVBufferDebug;

		var _corners = GetCorners();
		var _ntl  = _corners[0];
		var _ntlx = _ntl.X;
		var _ntly = _ntl.Y;
		var _ntlz = _ntl.Z;
		var _ntr  = _corners[1];
		var _ntrx = _ntr.X;
		var _ntry = _ntr.Y;
		var _ntrz = _ntr.Z;
		var _nbl  = _corners[2];
		var _nblx = _nbl.X;
		var _nbly = _nbl.Y;
		var _nblz = _nbl.Z;
		var _nbr  = _corners[3];
		var _nbrx = _nbr.X;
		var _nbry = _nbr.Y;
		var _nbrz = _nbr.Z;
		var _ftl  = _corners[4];
		var _ftlx = _ftl.X;
		var _ftly = _ftl.Y;
		var _ftlz = _ftl.Z;
		var _ftr  = _corners[5];
		var _ftrx = _ftr.X;
		var _ftry = _ftr.Y;
		var _ftrz = _ftr.Z;
		var _fbl  = _corners[6];
		var _fblx = _fbl.X;
		var _fbly = _fbl.Y;
		var _fblz = _fbl.Z;
		var _fbr  = _corners[7];
		var _fbrx = _fbr.X;
		var _fbry = _fbr.Y;
		var _fbrz = _fbr.Z;

		vertex_begin(_vbuffer, BBMOD_VFORMAT_DEBUG.Raw);

		// Near plane
		vertex_position_3d(_vbuffer, _ntlx, _ntly, _ntlz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _ntrx, _ntry, _ntrz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _ntrx, _ntry, _ntrz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _nbrx, _nbry, _nbrz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _nbrx, _nbry, _nbrz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _nblx, _nbly, _nblz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _nblx, _nbly, _nblz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _ntlx, _ntly, _ntlz); vertex_color(_vbuffer, _color, _alpha);

		// Far plane
		vertex_position_3d(_vbuffer, _ftlx, _ftly, _ftlz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _ftrx, _ftry, _ftrz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _ftrx, _ftry, _ftrz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _fbrx, _fbry, _fbrz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _fbrx, _fbry, _fbrz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _fblx, _fbly, _fblz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _fblx, _fbly, _fblz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _ftlx, _ftly, _ftlz); vertex_color(_vbuffer, _color, _alpha);

		// Sides
		vertex_position_3d(_vbuffer, _ntlx, _ntly, _ntlz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _ftlx, _ftly, _ftlz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _ntrx, _ntry, _ntrz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _ftrx, _ftry, _ftrz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _nbrx, _nbry, _nbrz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _fbrx, _fbry, _fbrz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _nblx, _nbly, _nblz); vertex_color(_vbuffer, _color, _alpha);
		vertex_position_3d(_vbuffer, _fblx, _fbly, _fblz); vertex_color(_vbuffer, _color, _alpha);

		vertex_end(_vbuffer);

		vertex_submit(_vbuffer, pr_linelist, -1);

		return self;
	};
}
