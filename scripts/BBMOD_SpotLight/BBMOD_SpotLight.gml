/// @func BBMOD_SpotLight([_color[, _position[, _range[, _direction[, _angleInner[, _angleOuter]]]]]])
///
/// @extends BBMOD_PunctualLight
///
/// @desc A spot light.
///
/// @param {Struct.BBMOD_Color} [_color] The light's color. Defaults to
/// {@link BBMOD_C_WHITE}.
/// @param {Struct.BBMOD_Vec3} [_position] The light's position. Defaults to
/// `(0, 0, 0)` if `undefined`.
/// @param {Real} [_range] The light's range. Defaults to 1.
/// @param {Struct.BBMOD_Vec3} [_direction] The light's direction. Defaults to
/// {@link BBMOD_VEC3_FORWARD} if `undefined`.
/// @param {Real} [_angleInner] The inner cone angle in degrees. Defaults to 10.
/// @param {Real} [_angleOuter] The outer cone angle in degrees. Defaults to 20.
function BBMOD_SpotLight(
	_color=BBMOD_C_WHITE,
	_position=undefined,
	_range=1.0,
	_direction=undefined,
	_angleInner=10,
	_angleOuter=20
) : BBMOD_PunctualLight(_color, _position, _range) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_Vec3} The direction of the light. The default value is
	/// `(1, 0, 0)`.
	Direction = _direction ?? BBMOD_VEC3_FORWARD;

	/// @var {Real} The inner cone angle in degrees. Default value is 10.
	AngleInner = _angleInner;

	/// @var {Real} The inner cone angle in degrees. Default value is 20.
	AngleOuter = _angleOuter;

	__getZFar = __get_shadowmap_zfar;

	__getViewMatrix = __get_shadowmap_view;

	__getProjMatrix = __get_shadowmap_projection;

	__getShadowmapMatrix = __get_shadowmap_matrix;

	static __get_shadowmap_zfar = function () {
		gml_pragma("forceinline");
		return Range;
	};

	static __get_shadowmap_view = function () {
		gml_pragma("forceinline");
		return matrix_build_lookat(
			Position.X,
			Position.Y,
			Position.Z,
			Position.X + Direction.X,
			Position.Y + Direction.Y,
			Position.Z + Direction.Z,
			0.0, 0.0, 1.0); // TODO: Find the up vector
	};

	static __get_shadowmap_projection = function () {
		gml_pragma("forceinline");
		return matrix_build_projection_perspective_fov(
			AngleOuter * 2.0, 1.0, 0.01, Range);
	};

	static __get_shadowmap_matrix = function () {
		gml_pragma("forceinline");
		return matrix_multiply(
			__getViewMatrix(),
			__getProjMatrix());
	};
}
