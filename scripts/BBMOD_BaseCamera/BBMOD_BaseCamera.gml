/// @var {Struct.BBMOD_BaseCamera} The last used camera. Can be `undefined`.
/// @private
global.__bbmodCameraCurrent = undefined;

/// @func BBMOD_BaseCamera()
///
/// @extends BBMOD_Class
///
/// @desc A camera with support for both orthographic and perspective
/// projection.
///
/// @see BBMOD_Camera
function BBMOD_BaseCamera()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

	/// @var {camera} An underlying GameMaker camera.
	/// @readonly
	Raw = camera_create();

	/// @var {Real} The camera's exposure value. Defaults to `1`.
	Exposure = 1.0;

	/// @var {Struct.BBMOD_Vec3} The camera's positon. Defaults to `(0, 0, 0)`.
	Position = new BBMOD_Vec3(0.0);

	/// @var {Struct.BBMOD_Vec3} A position where the camera is looking at.
	Target = BBMOD_VEC3_FORWARD;

	/// @var {Struct.BBMOD_Vec3} The up vector.
	Up = BBMOD_VEC3_UP;

	/// @var {Real} The camera's field of view. Defaults to `60`.
	/// @note This does not have any effect when {@link BBMOD_BaseCamera.Orthographic}
	/// is enabled.
	Fov = 60.0;

	/// @var {Real} The camera's aspect ratio. Defaults to
	/// `window_get_width() / window_get_height()`.
	AspectRatio = window_get_width() / window_get_height();

	/// @var {Real} Distance to the near clipping plane. Anything closer to the
	/// camera than this will not be visible. Defaults to `0.1`.
	/// @note This can be a negative value if {@link BBMOD_BaseCamera.Orthographic}
	/// is enabled.
	ZNear = 0.1;

	/// @var {Real} Distance to the far clipping plane. Anything farther from
	/// the camera than this will not be visible. Defaults to `32768`.
	ZFar = 32768.0;

	/// @var {Bool} Use `true` to enable orthographic projection. Defaults to
	/// `false` (perspective projection).
	Orthographic = false;

	/// @var {Real} The width of the orthographic projection. If `undefined`,
	/// then it is computed from {@link BBMOD_BaseCamera.Height} using
	/// {@link BBMOD_BaseCamera.AspectRatio}. Defaults to the window's width.
	/// @see BBMOD_BaseCamera.Orthographic
	Width = window_get_width();

	/// @var {Real} The height of the orthographic projection. If `undefined`,
	/// then it is computed from {@link BBMOD_BaseCamera.Width} using
	/// {@link BBMOD_BaseCamera.AspectRatio}. Defaults to `undefined`.
	/// @see BBMOD_BaseCamera.Orthographic
	Height = undefined;

	/// @var {Bool} If `true` then the camera updates position and orientation
	/// of the 3D audio listener in the {@link BBMOD_BaseCamera.update_matrices}
	/// method. Defaults to `true`.
	AudioListener = true;

	/// @var {Array<Real>} The `view * projection` matrix.
	/// @note This is updated each time {@link BBMOD_BaseCamera.update_matrices}
	/// is called.
	/// @readonly
	ViewProjectionMatrix = matrix_build_identity();

	/// @func __build_proj_mat()
	///
	/// @desc Builds a projection matrix based on the camera's properties.
	///
	/// @return {Array<Real>} The projection matrix.
	///
	/// @private
	static __build_proj_mat = function () {
		var _proj;
		if (Orthographic)
		{
			var _width = (Width != undefined) ? Width : (Height * AspectRatio);
			var _height = (Height != undefined) ? Height : (Width / AspectRatio);
			_proj = matrix_build_projection_ortho(_width, -_height, ZNear, ZFar);
		}
		else
		{
			_proj = matrix_build_projection_perspective_fov(
				-Fov, -AspectRatio, ZNear, ZFar);
		}
		return _proj;
	};

	/// @func update_matrices()
	///
	/// @desc Recomputes camera's view and projection matrices.
	///
	/// @return {Struct.BBMOD_BaseCamera} Returns `self`.
	///
	/// @note This is called automatically in the {@link BBMOD_BaseCamera.update}
	/// method, so you do not need to call this unless you modify
	/// {@link BBMOD_BaseCamera.Position} or {@link BBMOD_BaseCamera.Target}
	/// after the `update` method.
	///
	/// @example
	/// ```gml
	/// /// @desc Step event
	/// camera.set_mouselook(true);
	/// camera.update(delta_time);
	/// if (camera.Position.Z < 0.0)
	/// {
	///     camera.Position.Z = 0.0;
	/// }
	/// camera.update_matrices();
	/// ```
	static update_matrices = function () {
		gml_pragma("forceinline");

		var _view = matrix_build_lookat(
			Position.X, Position.Y, Position.Z,
			Target.X, Target.Y, Target.Z,
			Up.X, Up.Y, Up.Z);
		camera_set_view_mat(Raw, _view);

		var _proj = __build_proj_mat();
		camera_set_proj_mat(Raw, _proj);

		// Note: Using _view and _proj mat straight away leads into a weird result...
		ViewProjectionMatrix = matrix_multiply(
			get_view_mat(),
			get_proj_mat());

		if (AudioListener)
		{
			audio_listener_position(Position.X, Position.Y, Position.Z);
			audio_listener_orientation(
				Target.X, Target.Y, Target.Z,
				Up.X, Up.Y, Up.Z);
		}

		return self;
	}

	/// @func update(_deltaTime)
	///
	/// @desc Updates camera's matrices.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_BaseCamera} Returns `self`.
	static update = function (_deltaTime) {
		update_matrices();
		return self;
	};

	/// @func get_view_mat()
	///
	/// @desc Retrieves camera's view matrix.
	///
	/// @return {Array<Real>} The view matrix.
	static get_view_mat = function () {
		gml_pragma("forceinline");

		if (os_browser == browser_not_a_browser)
		{
			// This returns a struct in HTML5 for some reason...
			return camera_get_view_mat(Raw);
		}

		var _view = matrix_get(matrix_view);
		var _proj = matrix_get(matrix_projection);
		camera_apply(Raw);
		var _retval = matrix_get(matrix_view);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _proj);
		return _retval;
	};

	/// @func get_proj_mat()
	///
	/// @desc Retrieves camera's projection matrix.
	///
	/// @return {Array<Real>} The projection matrix.
	static get_proj_mat = function () {
		gml_pragma("forceinline");

		if (os_browser == browser_not_a_browser)
		{
			// This returns a struct in HTML5 for some reason...
			return camera_get_proj_mat(Raw);
		}

		var _view = matrix_get(matrix_view);
		var _proj = matrix_get(matrix_projection);
		camera_apply(Raw);
		var _retval = matrix_get(matrix_projection);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _proj);
		return _retval;
	};

	/// @func get_right()
	///
	/// @desc Retrieves a vector pointing right relative to the camera's
	/// direction.
	///
	/// @return {Struct.BBMOD_Vec3} The right vector.
	static get_right = function () {
		gml_pragma("forceinline");
		var _view = get_view_mat();
		return new BBMOD_Vec3(
			_view[0],
			_view[4],
			_view[8]
		);
	};

	/// @func get_up()
	///
	/// @desc Retrieves a vector pointing up relative to the camera's
	/// direction.
	///
	/// @return {Struct.BBMOD_Vec3} The up vector.
	static get_up = function () {
		gml_pragma("forceinline");
		var _view = get_view_mat();
		return new BBMOD_Vec3(
			_view[1],
			_view[5],
			_view[9]
		);
	};

	/// @func get_forward()
	///
	/// @desc Retrieves a vector pointing forward in the camera's direction.
	///
	/// @return {Struct.BBMOD_Vec3} The forward vector.
	static get_forward = function () {
		gml_pragma("forceinline");
		var _view = get_view_mat();
		return new BBMOD_Vec3(
			_view[2],
			_view[6],
			_view[10]
		);
	};

	/// @func world_to_screen(_position[, _screenWidth[, _screenHeight]])
	///
	/// @desc Computes screen-space position of a point in world-space.
	///
	/// @param {Struct.BBMOD_Vec3} _position The world-space position.
	/// @param {Real} [_screenWidth] The width of the screen. If `undefined`, it
	/// is retrieved using `window_get_width`.
	/// @param {Real} [_screenHeight] The height of the screen. If `undefined`,
	/// it is retrieved using `window_get_height`.
	///
	/// @return {Struct.BBMOD_Vec4} The screen-space position or `undefined` if
	/// the point is outside of the screen.
	///
	/// @note This requires {@link BBMOD_BaseCamera.ViewProjectionMatrix}, so you
	/// should use this *after* {@link BBMOD_BaseCamera.update_matrices} (or
	/// {@link BBMOD_BaseCamera.update}) is called!
	static world_to_screen = function (_position, _screenWidth=undefined, _screenHeight=undefined) {
		gml_pragma("forceinline");
		_screenWidth ??= window_get_width();
		_screenHeight ??= window_get_height();
		var _screenPos = new BBMOD_Vec4(_position.X, _position.Y, _position.Z, 1.0)
			.Transform(ViewProjectionMatrix);
		if (_screenPos.Z < 0.0)
		{
			return undefined;
		}
		_screenPos = _screenPos.Scale(1.0 / _screenPos.W);
		_screenPos.X = ((_screenPos.X * 0.5) + 0.5) * _screenWidth;
		_screenPos.Y = (1.0 - ((_screenPos.Y * 0.5) + 0.5)) * _screenHeight;
		return _screenPos;
	};

	/// @func screen_point_to_vec3(_vector[, _renderer])
	///
	/// @desc Unprojects a position on the screen into a direction in world-space.
	///
	/// @param {Struct.BBMOD_Vector2} _vector The position on the screen.
	/// @param {Struct.BBMOD_Renderer} [_renderer] A renderer or `undefined`.
	///
	/// @return {Struct.BBMOD_Vec3} The world-space direction.
	static screen_point_to_vec3 = function (_vector, _renderer=undefined) {
		var _forward = get_forward();
		var _up = get_up();
		var _right = get_right();
		var _tFov = dtan(Fov * 0.5);
		_up = _up.Scale(_tFov);
		_right = _right.Scale(_tFov * AspectRatio);
		var _screenWidth = _renderer ? _renderer.get_width() : window_get_width();
		var _screenHeight = _renderer ? _renderer.get_height() : window_get_height();
		var _screenX = _vector.X - (_renderer ? _renderer.X : 0);
		var _screenY = _vector.Y - (_renderer ? _renderer.Y : 0);
		var _ray = _forward.Add(_up.Scale(1.0 - 2.0 * (_screenY / _screenHeight))
			.Add(_right.Scale(2.0 * (_screenX / _screenWidth) - 1.0)));
		return _ray.Normalize();
	};

	/// @func apply()
	///
	/// @desc Applies the camera.
	///
	/// @return {Struct.BBMOD_BaseCamera} Returns `self`.
	///
	/// @example
	/// Following code renders a model from the camera's view.
	/// ```gml
	/// camera.apply();
	/// bbmod_material_reset();
	/// model.submit();
	/// bbmod_material_reset();
	/// ```
	///
	/// @note This also overrides the camera position and exposure passed to
	/// shaders using {@link bbmod_camera_set_position} and
	/// {@link bbmod_camera_set_exposure} respectively!
	static apply = function () {
		gml_pragma("forceinline");
		global.__bbmodCameraCurrent = self;
		camera_apply(Raw);
		bbmod_camera_set_position(Position.Clone());
		bbmod_camera_set_zfar(ZFar);
		bbmod_camera_set_exposure(Exposure);
		return self;
	};

	static destroy = function () {
		Class_destroy();
		camera_destroy(Raw);
		if (global.__bbmodCameraCurrent == self)
		{
			global.__bbmodCameraCurrent = undefined;
		}
		return undefined;
	};
}
