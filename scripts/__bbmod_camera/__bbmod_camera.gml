/// @var {Struct.BBMOD_Vec3}
/// @private
global.__bbmodCameraPosition = new BBMOD_Vec3();

/// @var {Real} Distance to the far clipping plane.
/// @private
global.__bbmodZFar = 1.0;

/// @var {Real}
/// @private
global.__bbmodCameraExposure = 1.0;

/// @func bbmod_camera_get_position()
///
/// @desc Retrieves the position of the camera that is passed to shaders.
///
/// @return {Struct.BBMOD_Vec3} The camera position.
///
/// @see bbmod_camera_set_position
function bbmod_camera_get_position()
{
	gml_pragma("forceinline");
	return global.__bbmodCameraPosition;
}

/// @func bbmod_camera_set_position(_position)
///
/// @desc Defines position of the camera passed to shaders.
///
/// @param {Struct.BBMOD_Vec3} _position The new camera position.
///
/// @see bbmod_camera_get_position
function bbmod_camera_set_position(_position)
{
	gml_pragma("forceinline");
	global.__bbmodCameraPosition = _position;
}

/// @func bbmod_camera_get_zfar()
///
/// @desc Retrieves distance to the far clipping plane passed to shaders.
///
/// @return {Real} The distance to the far clipping plane.
///
/// @see bbmod_camera_set_zfar
function bbmod_camera_get_zfar()
{
	gml_pragma("forceinline");
	return global.__bbmodZFar;
}

/// @func bbmod_camera_set_zfar(_value)
///
/// @desc Defines distance to the far clipping plane passed to shaders.
///
/// @param {Real} _value The new distance to the far clipping plane.
///
/// @see bbmod_camera_get_zfar
function bbmod_camera_set_zfar(_value)
{
	gml_pragma("forceinline");
	global.__bbmodZFar = _value;
}

/// @func bbmod_camera_get_exposure()
///
/// @desc Retrieves camera exposure value passed to shaders.
///
/// @return {Real} The camera exposure value.
///
/// @see bbmod_camera_set_exposure
function bbmod_camera_get_exposure()
{
	gml_pragma("forceinline");
	return global.__bbmodCameraExposure;
}

/// @func bbmod_camera_set_exposure(_exposure)
///
/// @desc Defines camera exposure value passed to shaders.
///
/// @param {Real} _exposure The new camera exposure value.
///
/// @see bbmod_camera_get_exposure
function bbmod_camera_set_exposure(_exposure)
{
	gml_pragma("forceinline");
	global.__bbmodCameraExposure = _exposure;
}
