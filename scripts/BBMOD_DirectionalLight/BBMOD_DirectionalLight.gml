/// @var {Struct.BBMOD_DirectionalLight}
/// @private
global.__bbmodDirectionalLight = undefined;

/// @func BBMOD_DirectionalLight([_color[, _direction]])
///
/// @extends BBMOD_Light
///
/// @desc A directional light.
///
/// @param {Struct.BBMOD_Color} [_color] The light's color. Defaults to
/// {@link BBMOD_C_WHITE} if `undefined`.
/// @param {Struct.BBMOD_Vec3} [_direction] The light's direction. Defaults to
/// `(-1, 0, -1)` if `undefined`.
function BBMOD_DirectionalLight(_color=undefined, _direction=undefined)
	: BBMOD_Light() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_Color} The color of the light. Defaul value is
	/// {@link BBMOD_C_WHITE}.
	Color = _color ?? BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Vec3} The direction of the light. Default value is
	/// `(-1, 0, -1)`.
	Direction = _direction ?? new BBMOD_Vec3(-1.0, 0.0, -1.0).Normalize();

	/// @var {Real} The area captured by the shadowmap. Defaults to 1024.
	ShadowmapArea = 1024;

	__getZFar = __get_shadowmap_zfar;

	__getViewMatrix = __get_shadowmap_view;

	__getProjMatrix = __get_shadowmap_projection;

	__getShadowmapMatrix = __get_shadowmap_matrix;

	static __get_shadowmap_zfar = function () {
		gml_pragma("forceinline");
		return ShadowmapArea;
	};

	static __get_shadowmap_view = function () {
		gml_pragma("forceinline");
		var _position = bbmod_camera_get_position();
		return matrix_build_lookat(
			_position.X,
			_position.Y,
			_position.Z,
			_position.X + Direction.X,
			_position.Y + Direction.Y,
			_position.Z + Direction.Z,
			0.0, 0.0, 1.0); // TODO: Find the up vector
	};

	static __get_shadowmap_projection = function () {
		gml_pragma("forceinline");
		return matrix_build_projection_ortho(
			ShadowmapArea, ShadowmapArea, -ShadowmapArea * 0.5, ShadowmapArea * 0.5);
	};

	static __get_shadowmap_matrix = function () {
		gml_pragma("forceinline");
		return matrix_multiply(
			__getViewMatrix(),
			__getProjMatrix());
	};
}

/// @func bbmod_light_directional_get()
///
/// @desc Retrieves the directional light passed to shaders.
///
/// @return {Struct.BBMOD_DirectionalLight} The directional light or `undefined`.
///
/// @see bbmod_light_directional_set
/// @see BBMOD_DirectionalLight
function bbmod_light_directional_get()
{
	gml_pragma("forceinline");
	return global.__bbmodDirectionalLight;
}

/// @func bbmod_light_directional_set(_light)
///
/// @desc Defines the directional light passed to shaders.
///
/// @param {Struct.BBMOD_DirectionalLight} _light The new directional light or
/// `undefined`.
///
/// @see bbmod_light_directional_get
/// @see BBMOD_DirectionalLight
function bbmod_light_directional_set(_light)
{
	gml_pragma("forceinline");
	global.__bbmodDirectionalLight = _light;
}
