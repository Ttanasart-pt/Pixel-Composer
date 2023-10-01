// feather ignore all

/// @func BBMOD_Quaternion([_x, _y, _z, _w])
///
/// @desc A quaternion.
///
/// @param {Real} [_x] The first component of the quaternion. Defaults to 0.
/// @param {Real} [_y] The second component of the quaternion. Defaults to 0.
/// @param {Real} [_z] The third component of the quaternion. Defaults to 0.
/// @param {Real} [_w] The fourth component of the quaternion. Defaults to 1.
///
/// @note If you leave the arguments to their default values, then an identity
/// quaternion is created.
function BBMOD_Quaternion(_x=0.0, _y=0.0, _z=0.0, _w=1.0) constructor
{
	/// @var {Real} The first component of the quaternion.
	X = _x;

	/// @var {Real} The second component of the quaternion.
	Y = _y;

	/// @var {Real} The third component of the quaternion.
	Z = _z;

	/// @var {Real} The fourth component of the quaternion.
	W = _w;
	
	static set = function(x, y, z, w) {
		gml_pragma("forceinline");
		X = x;
		Y = y;
		Z = z;
		W = w;
		return self;
	}

	/// @func Add(_q)
	///
	/// @desc Adds quaternions and returns the result as a new quaternion.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Add = function (_q) {
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(
			X + _q.X,
			Y + _q.Y,
			Z + _q.Z,
			W + _q.W
		);
	};

	/// @func Clone()
	///
	/// @desc Creates a clone of the quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Clone = function () {
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(X, Y, Z, W);
	};

	/// @func Conjugate()
	///
	/// @desc Conjugates the quaternion and returns the result as a quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Conjugate = function () {
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(-X, -Y, -Z, W);
	};

	/// @func Copy(_dest)
	///
	/// @desc Copies components of the quaternion into other quaternion.
	///
	/// @param {Struct.BBMOD_Quaternion} _dest The destination quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static Copy = function (_dest) {
		gml_pragma("forceinline");
		_dest.X = X;
		_dest.Y = Y;
		_dest.Z = Z;
		_dest.W = W;
		return self;
	};

	/// @func Dot(_q)
	///
	/// @desc Computes a dot product of two dual quaternions.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	///
	/// @return {Real} The dot product of the quaternions.
	static Dot = function (_q) {
		gml_pragma("forceinline");
		return (
			  X * _q.X
			+ Y * _q.Y
			+ Z * _q.Z
			+ W * _q.W
		);
	};

	/// @func Exp()
	///
	/// @desc Computes an exponential map of the quaternion and returns
	/// the result as a new quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Exp = function () {
		gml_pragma("forceinline");
		var _length = Length();
		if (_length >= math_get_epsilon())
		{
			var _sinc = Sinc(_length);
			return new BBMOD_Quaternion(
				X * _sinc,
				Y * _sinc,
				Z * _sinc,
				exp(W) * cos(_length)
			);
		}
		return new BBMOD_Quaternion(0.0, 0.0, 0.0, exp(W));
	};

	/// @func FromArray(_array[, _index])
	///
	/// @desc Loads quaternion components `(x, y, z, w)` from an array.
	///
	/// @param {Array<Real>} _array The array to read the quaternion components
	/// from.
	/// @param {Real} [_index] The index to start reading the quaternion
	/// components from. Defaults to 0.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static FromArray = function (_array, _index=0) {
		gml_pragma("forceinline");
		X = _array[_index];
		Y = _array[_index + 1];
		Z = _array[_index + 2];
		W = _array[_index + 3];
		return self;
	};

	/// @func FromAxisAngle(_axis, _angle)
	///
	/// @desc Initializes the quaternion using an axis and an angle.
	///
	/// @param {Struct.BBMOD_Vec3} _axis The axis of rotaiton.
	///
	/// @param {Real} _angle The rotation angle.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static FromAxisAngle = function (_axis, _angle) {
		gml_pragma("forceinline");
		_angle = -_angle;
		var _sinHalfAngle = dsin(_angle * 0.5);
		X = is_nan(_axis.X)? 0 : _axis.X * _sinHalfAngle;
		Y = is_nan(_axis.Y)? 0 : _axis.Y * _sinHalfAngle;
		Z = is_nan(_axis.Z)? 0 : _axis.Z * _sinHalfAngle;
		W = dcos(_angle * 0.5);
		return self;
	};

	/// @func FromBuffer(_buffer, _type)
	///
	/// @desc Loads quaternion components `(x, y, z, w)` from a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to read the quaternion components
	/// from.
	///
	/// @param {Constant.BufferDataType} [_type] The type of each component.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static FromBuffer = function (_buffer, _type) {
		gml_pragma("forceinline");
		X = buffer_read(_buffer, _type);
		Y = buffer_read(_buffer, _type);
		Z = buffer_read(_buffer, _type);
		W = buffer_read(_buffer, _type);
		return self;
	};

	/// @func FromEuler(_x, _y, _z)
	///
	/// @desc Initializes the quaternion using euler angles.
	///
	/// @param {Real} _x The rotation around the X axis (in degrees).
	/// @param {Real} _y The rotation around the Y axis (in degrees).
	/// @param {Real} _z The rotation around the Z axis (in degrees).
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	///
	/// @note The order of rotations is YXZ, same as in the `matrix_build`
	/// function.
	static FromEuler = function (_x, _y, _z) {
		gml_pragma("forceinline");

		_x = -_x * 0.5;
		_y = -_y * 0.5;
		_z = -_z * 0.5;

		var _q1Sin, _q1Cos, _temp;
		var _qX, _qY, _qZ, _qW;

		_q1Sin = dsin(_z);
		_q1Cos = dcos(_z);

		_temp = dsin(_x);

		_qX = _q1Cos * _temp;
		_qY = _q1Sin * _temp;

		_temp = dcos(_x);

		_qZ = _q1Sin * _temp;
		_qW = _q1Cos * _temp;

		_q1Sin = dsin(_y);
		_q1Cos = dcos(_y);

		X = _qX * _q1Cos - _qZ * _q1Sin;
		Y = _qW * _q1Sin + _qY * _q1Cos;
		Z = _qZ * _q1Cos + _qX * _q1Sin;
		W = _qW * _q1Cos - _qY * _q1Sin;

		return self;
	};

	/// @func FromLookRotation(_forward, _up)
	///
	/// @desc Initializes the quaternion using a forward and an up vector. These
	/// vectors must not be parallel! If they are, the quaternion will be set to an
	/// identity.
	///
	/// @param {Struct.BBMOD_Vec3} _forward The vector facing forward.
	/// @param {Struct.BBMOD_Vec3} _up The vector facing up.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static FromLookRotation = function (_forward, _up) {
		gml_pragma("forceinline");
		
		_forward = new BBMOD_Vec3(_forward);
		_up      = new BBMOD_Vec3(_up);

		if (!_forward.Orthonormalize(_up))
		{
			X = 0.0;
			Y = 0.0;
			Z = 0.0;
			W = 1.0;
			return self;
		}

		var _right = _up.Cross(_forward);
		var _w = sqrt(abs(1.0 + _right.X + _up.Y + _forward.Z)) * 0.5;
		var _w4Recip = 1.0 / (4.0 * _w);

		X = (_up.Z - _forward.Y) * _w4Recip;
		Y = (_forward.X - _right.Z) * _w4Recip;
		Z = (_right.Y - _up.X) * _w4Recip;
		W = _w;
		return self;
	};
	
	static FromMatrix = function(rotMatrix) {
		gml_pragma("forceinline");

		W = sqrt(1 + rotMatrix[0] + rotMatrix[5] + rotMatrix[10]) / 2;
		X =  (rotMatrix[9] - rotMatrix[6]) / (4 * W);
		Y =  (rotMatrix[2] - rotMatrix[8]) / (4 * W);
		Z =  (rotMatrix[4] - rotMatrix[1]) / (4 * W);
		return self;
	}

	/// @func GetAngle()
	///
	/// @desc Retrieves the rotation angle of the quaternion.
	///
	/// @return {Real} The rotation angle.
	static GetAngle = function () {
		gml_pragma("forceinline");
		return radtodeg(arccos(W) * 2.0);
	};

	/// @func GetAxis()
	///
	/// @desc Retrieves the axis of rotation of the quaternion.
	///
	/// @return {Struct.BBMOD_Vec3} The axis of rotation.
	static GetAxis = function () {
		gml_pragma("forceinline");
		var _sinThetaInv = 1.0 / sin(arccos(W));
		return new BBMOD_Vec3(
			X * _sinThetaInv,
			Y * _sinThetaInv,
			Z * _sinThetaInv
		);
	};

	/// @func Inverse()
	///
	/// @desc Computes an inverse of the quaternion and returns the result
	/// as a new quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Inverse = function () {
		gml_pragma("forceinline");
		return Conjugate().Scale(1.0 / Length());
	};

	/// @func Length()
	///
	/// @desc Computes the length of the quaternion.
	///
	/// @return {Real} The length of the quaternion.
	static Length = function () {
		gml_pragma("forceinline");
		return sqrt(
			  X * X
			+ Y * Y
			+ Z * Z
			+ W * W
		);
	};

	/// @func LengthSqr()
	///
	/// @desc Computes a squared length of the quaternion.
	///
	/// @return {Real} The squared length of the quaternion.
	static LengthSqr = function () {
		gml_pragma("forceinline");
		return (
			  X * X
			+ Y * Y
			+ Z * Z
			+ W * W
		);
	};

	/// @func Lerp(_q, _s)
	///
	/// @desc Computes a linear interpolation of two quaternions
	/// and returns the result as a new quaternion.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	/// @param {Real} _s The interpolation factor.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Lerp = function (_q, _s) {
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(
			lerp(X, _q.X, _s),
			lerp(Y, _q.Y, _s),
			lerp(Z, _q.Z, _s),
			lerp(W, _q.W, _s)
		);
	};

	/// @func Log()
	///
	/// @desc Computes the logarithm map of the quaternion and returns the
	/// result as a new quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Log = function () {
		gml_pragma("forceinline");
		var _length = Length();
		var _w = logn(2.71828, _length);
		var _a = arccos(W / _length);
		if (_a >= math_get_epsilon())
		{
			var _mag = 1.0 / _length / Sinc(_a);
			return new BBMOD_Quaternion(
				X * _mag,
				Y * _mag,
				Z * _mag,
				_w
			);
		}
		return new BBMOD_Quaternion(0.0, 0.0, 0.0, _w);
	};

	/// @func Mul(_q)
	///
	/// @desc Multiplies two quaternions and returns the result as a new
	/// quaternion.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Mul = function (_q) {
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(
			W * _q.X + X * _q.W + Y * _q.Z - Z * _q.Y,
			W * _q.Y + Y * _q.W + Z * _q.X - X * _q.Z,
			W * _q.Z + Z * _q.W + X * _q.Y - Y * _q.X,
			W * _q.W - X * _q.X - Y * _q.Y - Z * _q.Z
		);
	};

	/// @func Normalize()
	///
	/// @desc Normalizes the quaternion and returns the result as a new
	/// quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Normalize = function () {
		gml_pragma("forceinline");
		var _lengthSqr = LengthSqr();
		if(_lengthSqr == 0)
			return new BBMOD_Quaternion();
		
		if (_lengthSqr >= math_get_epsilon())
			return Scale(1.0 / sqrt(_lengthSqr));
		return Clone();
	};

	/// @func Rotate(_v)
	///
	/// @desc Rotates a vector using the quaternion and returns the result
	/// as a new vector.
	///
	/// @param {Struct.BBMOD_Vec3} _v The vector to rotate.
	///
	/// @return {Struct.BBMOD_Vec3} The created vector.
	static Rotate = function (_v) {
		gml_pragma("forceinline");
		
		var _tovec = is_instanceof(_v, __vec3);
		if(_tovec) _v = new BBMOD_Vec3(_v.x, _v.y, _v.z);
		
		var _q = Normalize();
		var _V = new BBMOD_Quaternion(_v.X, _v.Y, _v.Z, 0.0);
		var _rot = _q.Mul(_V).Mul(_q.Conjugate());
		
		var res;
		if(_tovec)  res = new __vec3(_rot.X, _rot.Y, _rot.Z);
		else		res = new BBMOD_Vec3(_rot.X, _rot.Y, _rot.Z);
		
		return res;
	};

	/// @func Scale(_s)
	///
	/// @desc Scales each component of the quaternion by a real value and
	/// returns the result as a new quaternion.
	///
	/// @param {Real} _s The value to scale the quaternion by.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Scale = function (_s) {
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(
			X * _s,
			Y * _s,
			Z * _s,
			W * _s
		);
	};

	static Sinc = function (_x) {
		gml_pragma("forceinline");
		return (_x >= math_get_epsilon()) ? (sin(_x) / _x) : 1.0;
	};

	/// @func Slerp(_q, _s)
	///
	/// @desc Computes a spherical linear interpolation of two quaternions
	/// and returns the result as a new quaternion.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	/// @param {Real} _s The interpolation factor.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Slerp = function (_q, _s) {
		gml_pragma("forceinline");

		var _q10 = X;
		var _q11 = Y;
		var _q12 = Z;
		var _q13 = W;

		var _q20 = _q.X;
		var _q21 = _q.Y;
		var _q22 = _q.Z;
		var _q23 = _q.W;

		var _norm;

		_norm = 1.0 / sqrt(_q10 * _q10
			+ _q11 * _q11
			+ _q12 * _q12
			+ _q13 * _q13);

		_q10 *= _norm;
		_q11 *= _norm;
		_q12 *= _norm;
		_q13 *= _norm;

		_norm = sqrt(_q20 * _q20
			+ _q21 * _q21
			+ _q22 * _q22
			+ _q23 * _q23);

		_q20 *= _norm;
		_q21 *= _norm;
		_q22 *= _norm;
		_q23 *= _norm;

		var _dot = _q10 * _q20
			+ _q11 * _q21
			+ _q12 * _q22
			+ _q13 * _q23;

		if (_dot < 0.0)
		{
			_dot = -_dot;
			_q20 *= -1.0;
			_q21 *= -1.0;
			_q22 *= -1.0;
			_q23 *= -1.0;
		}

		if (_dot > 0.9995)
		{
			return new BBMOD_Quaternion(
				lerp(_q10, _q20, _s),
				lerp(_q11, _q21, _s),
				lerp(_q12, _q22, _s),
				lerp(_q13, _q23, _s)
			);
		}

		var _theta0 = arccos(_dot);
		var _theta = _theta0 * _s;
		var _sinTheta = sin(_theta);
		var _sinTheta0 = sin(_theta0);
		var _s2 = _sinTheta / _sinTheta0;
		var _s1 = cos(_theta) - (_dot * _s2);

		return new BBMOD_Quaternion(
			(_q10 * _s1) + (_q20 * _s2),
			(_q11 * _s1) + (_q21 * _s2),
			(_q12 * _s1) + (_q22 * _s2),
			(_q13 * _s1) + (_q23 * _s2)
		);
	};

	/// @func ToArray([_array[, _index]])
	///
	/// @desc Writes components `(x, y, z, w)` of the quaternion into an array.
	///
	/// @param {Array<Real>} [_array] The destination array. If not defined, a
	/// new one is created.
	/// @param {Real} [_index] The index to start writing to. Defaults to 0.
	///
	/// @return {Array<Real>} Returns the destination array.
	static ToArray = function (_array=undefined, _index=0) {
		gml_pragma("forceinline");
		_array ??= array_create(4, 0.0);
		_array[@ _index]     = X;
		_array[@ _index + 1] = Y;
		_array[@ _index + 2] = Z;
		_array[@ _index + 3] = W;
		return _array;
	};

	/// @func ToBuffer(_buffer, _type)
	///
	/// @desc Writes the quaternion into a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write the quaternion to.
	/// @param {Constant.BufferDataType} _type The type of each component.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static ToBuffer = function (_buffer, _type) {
		gml_pragma("forceinline");
		buffer_write(_buffer, _type, X);
		buffer_write(_buffer, _type, Y);
		buffer_write(_buffer, _type, Z);
		buffer_write(_buffer, _type, W);
		return self;
	};
	
	static ToEuler = function() {
		var ysqr = Y * Y;

	    // roll (x-axis rotation)
	    var t0 = +2.0 * (W * X + Y * Z);
	    var t1 = +1.0 - 2.0 * (X * X + ysqr);
	    var roll = arctan2(t0, t1);

	    // pitch (y-axis rotation)
	    var t2 = +2.0 * (W * Y - Z * X);
	    t2 = clamp(t2, -1.0, 1.0);  // Prevent numerical instability
	    var pitch = arcsin(t2);

	    // yaw (z-axis rotation)
	    var t3 = +2.0 * (W * Z + X * Y);
	    var t4 = +1.0 - 2.0 * (ysqr + Z * Z);
	    var yaw = arctan2(t3, t4);

	    // Convert radians to degrees
	    var _dx = roll * 180.0 / pi;
	    var _dy = pitch * 180.0 / pi;
	    var _dz = yaw * 180.0 / pi;

	    return new __rot3(_dx, _dy, _dz);
	}

	/// @func ToMatrix([_dest[, _index]])
	///
	/// @desc Converts quaternion into a matrix.
	///
	/// @param {Array<Real>} [_dest] The destination array. If not specified, a
	/// new one is created.
	/// @param {Real} [_index] The starting index in the destination array.
	/// Defaults to 0.
	///
	/// @return {Array<Real>} Returns the destination array.
	static ToMatrix = function (_dest=undefined, _index=0) {
		gml_pragma("forceinline");

		_dest ??= matrix_build_identity();
		
		var _norm = Normalize();
		
		var _temp0, _temp1, _temp2;
		var _q0 = _norm.X;
		var _q1 = _norm.Y;
		var _q2 = _norm.Z;
		var _q3 = _norm.W;

		_temp0 = _q0 * _q0;
		_temp1 = _q1 * _q1;
		_temp2 = _q2 * _q2;
		_dest[@ _index]      = 1.0 - 2.0 * (_temp1 + _temp2);
		_dest[@ _index + 5]  = 1.0 - 2.0 * (_temp0 + _temp2);
		_dest[@ _index + 10] = 1.0 - 2.0 * (_temp0 + _temp1);

		_temp0 = _q0 * _q1;
		_temp1 = _q3 * _q2;
		_dest[@ _index + 1] = 2.0 * (_temp0 + _temp1);
		_dest[@ _index + 4] = 2.0 * (_temp0 - _temp1);

		_temp0 = _q0 * _q2
		_temp1 = _q3 * _q1;
		_dest[@ _index + 2] = 2.0 * (_temp0 - _temp1);
		_dest[@ _index + 8] = 2.0 * (_temp0 + _temp1);

		_temp0 = _q1 * _q2;
		_temp1 = _q3 * _q0;
		_dest[@ _index + 6] = 2.0 * (_temp0 + _temp1);
		_dest[@ _index + 9] = 2.0 * (_temp0 - _temp1);

		return _dest;
	};
}
