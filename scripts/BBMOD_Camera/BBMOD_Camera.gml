/// @func BBMOD_Camera()
///
/// @extends BBMOD_BaseCamera
///
/// @desc A camera driven by angles and an object to follor, rather than raw
/// vectors. Supports both first-person and third-person view and comes with
/// a mouselook implementation that also works in HTML5.
///
/// @example
/// ```gml
/// // Create event
/// camera = new BBMOD_Camera();
/// camera.FollowObject = OPlayer;
/// camera.Zoom = 0.0; // Use 0.0 for FPS, > 0.0 for TPS
///
/// // End-Step event
/// camera.set_mouselook(true);
/// camera.update(delta_time);
///
/// // Draw event
/// camera.apply();
/// // Render scene here...
/// ```
function BBMOD_Camera()
	: BBMOD_BaseCamera() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Bool} If `true` then mouselook is enabled. Defaults to `false`.
	/// @readonly
	/// @see BBMOD_Camera.set_mouselook
	MouseLook = false;

	/// @var {Real} Controls the mouselook sensitivity. Defaults to `1`.
	MouseSensitivity = 1.0;

	/// @var {Struct.BBMOD_Vec2} The position on the screen where the cursor
	/// is locked when {@link BBMOD_Camera.MouseLook} is `true`. Can be
	/// `undefined`.
	/// @private
	__mouseLockAt = undefined;

	/// @var {Id.Instance} An id of an instance to follow or `undefined`. The
	/// object must have a `z` variable (position on the z axis) defined!
	/// Defaults to `undefined`.
	FollowObject = undefined;

	/// @var {Bool} Used to determine change of the object to follow.
	/// @private
	__followObjectLast = undefined;

	/// @var {Function} A function which remaps value in range `0..1` to a
	/// different `0..1` value. This is used to control the follow curve.
	/// If `undefined` then `lerp` is used. Defaults to `undefined`.
	FollowCurve = undefined;

	/// @var {Real} Controls lerp factor between the previous camera position
	/// and the object it follows. Defaults to `1`, which means the camera is
	/// immediately moved to its target position.
	/// {@link BBMOD_Camera.FollowObject} must not be `undefined` for this to
	/// have any effect.
	FollowFactor = 1.0;

	/// @var {Struct.BBMOD_Vec3} The camera's offset from its target. Defaults to
	/// `(0, 0, 0)`.
	Offset = new BBMOD_Vec3(0.0);

	/// @var {Real} The camera's horizontal direction. Defaults to `0`.
	Direction = 0.0;

	/// @var {Real} The camera's vertical direction. Automatically clamped
	/// between {@link BBMOD_Camera.DirectionUpMin} and
	/// {@link BBMOD_Camera.DirectionUpMax}. Defaults to `0`.
	DirectionUp = 0.0;

	/// @var {Real} Minimum angle that {@link BBMOD_Camrea.DirectionUp}
	/// can be. Use `undefined` to remove the limit. Default value is `-89`.
	DirectionUpMin = -89.0;

	/// @var {Real} Maximum angle that {@link BBMOD_Camrea.DirectionUp}
	/// can be. Use `undefined` to remove the limit. Default value is `89`.
	DirectionUpMax = 89.0;

	/// @var {Real} The angle of camera's rotation from side to side. Default
	/// value is `0`.
	Roll = 0.0;

	/// @var {Real} The camera's distance from its target. Use `0` for a
	/// first-person camera. Defaults to `0`.
	Zoom = 0.0;

	static update_matrices = function () {
		gml_pragma("forceinline");

		var _forward = BBMOD_VEC3_FORWARD;
		var _right = BBMOD_VEC3_RIGHT;
		var _up = BBMOD_VEC3_UP;

		var _quatZ = new BBMOD_Quaternion().FromAxisAngle(_up, Direction);
		_forward = _quatZ.Rotate(_forward);
		_right = _quatZ.Rotate(_right);
		_up = _quatZ.Rotate(_up);

		var _quatY = new BBMOD_Quaternion().FromAxisAngle(_right, DirectionUp);
		_forward = _quatY.Rotate(_forward);
		_right = _quatY.Rotate(_right);
		_up = _quatY.Rotate(_up);

		var _quatX = new BBMOD_Quaternion().FromAxisAngle(_forward, Roll);
		_forward = _quatX.Rotate(_forward);
		_right = _quatX.Rotate(_right);
		_up = _quatX.Rotate(_up);

		var _target = Position.Add(_forward);

		var _view = matrix_build_lookat(
			Position.X, Position.Y, Position.Z,
			_target.X, _target.Y, _target.Z,
			_up.X, _up.Y, _up.Z);
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
				_up.X, _up.Y, _up.Z);
		}

		Up = _up;

		return self;
	}

	/// @func set_mouselook(_enable)
	///
	/// @desc Enable/disable mouselook. This locks the mouse cursor at its
	/// current position when enabled.
	///
	/// @param {Bool} _enable USe `true` to enable mouselook.
	///
	/// @return {Struct.BBMOD_Camera} Returns `self`.
	static set_mouselook = function (_enable) {
		if (_enable)
		{
			if (os_browser != browser_not_a_browser)
			{
				bbmod_html5_pointer_lock();
			}

			if (__mouseLockAt == undefined)
			{
				__mouseLockAt = new BBMOD_Vec2(
					window_mouse_get_x(),
					window_mouse_get_y());
			}
		}
		else
		{
			__mouseLockAt = undefined;
		}
		MouseLook = _enable;
		return self;
	};

	/// @func update(_deltaTime[, _positionHandler])
	///
	/// @desc Handles mouselook, updates camera's position, matrices etc.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @param {Function} [_positionHandler] A function which takes the camera's
	/// position (@{link BBMOD_Vec3}) and returns a new position. This could be
	/// used for example for camera collisions in a third-person game. Defaults
	/// to `undefined`.
	///
	/// @return {Struct.BBMOD_Camera} Returns `self`.
	static update = function (_deltaTime, _positionHandler=undefined) {
		if (os_browser != browser_not_a_browser)
		{
			set_mouselook(bbmod_html5_pointer_is_locked());
		}

		if (MouseLook)
		{
			if (os_browser != browser_not_a_browser)
			{
				Direction -= bbmod_html5_pointer_get_movement_x() * MouseSensitivity;
				DirectionUp -= bbmod_html5_pointer_get_movement_y() * MouseSensitivity;
			}
			else
			{
				var _mouseX = window_mouse_get_x();
				var _mouseY = window_mouse_get_y();
				Direction += (__mouseLockAt.X - _mouseX) * MouseSensitivity;
				DirectionUp += (__mouseLockAt.Y - _mouseY) * MouseSensitivity;
				window_mouse_set(__mouseLockAt.X, __mouseLockAt.Y);
			}
		}

		if (DirectionUpMin != undefined)
		{
			DirectionUp = max(DirectionUp, DirectionUpMin);
		}
		if (DirectionUpMax != undefined)
		{
			DirectionUp = min(DirectionUp, DirectionUpMax);
		}

		var _offsetX = lengthdir_x(Offset.X, Direction - 90.0)
			+ lengthdir_x(Offset.Y, Direction);
		var _offsetY = lengthdir_y(Offset.X, Direction - 90.0)
			+ lengthdir_y(Offset.Y, Direction);
		var _offsetZ = Offset.Z;

		if (Zoom <= 0)
		{
			// First person camera
			if (FollowObject != undefined
				&& instance_exists(FollowObject))
			{
				Position.X = FollowObject.x + _offsetX;
				Position.Y = FollowObject.y + _offsetY;
				Position.Z = FollowObject.z + _offsetZ;
			}

			Target = Position.Add(new BBMOD_Vec3(
				+dcos(Direction),
				-dsin(Direction),
				+dtan(DirectionUp)
			));
		}
		else
		{
			// Third person camera
			if (FollowObject != undefined
				&& instance_exists(FollowObject))
			{
				var _targetNew = new BBMOD_Vec3(
					FollowObject.x + _offsetX,
					FollowObject.y + _offsetY,
					FollowObject.z + _offsetZ
				);

				if (__followObjectLast == FollowObject
					&& FollowFactor < 1.0)
				{
					var _factor = 1.0
						- bbmod_lerp_delta_time(0.0, 1.0, FollowFactor, _deltaTime);
					if (FollowCurve != undefined)
					{
						_factor = FollowCurve(0.0, 1.0, _factor);
					}
					Target = _targetNew.Lerp(Target, _factor);
				}
				else
				{
					Target = _targetNew;
				}
			}

			var _l = dcos(DirectionUp) * Zoom;
			Position = Target.Add(new BBMOD_Vec3(
				-dcos(Direction) * _l,
				+dsin(Direction) * _l,
				-dsin(DirectionUp) * Zoom
			));
		}

		if (_positionHandler != undefined)
		{
			Position = _positionHandler(Position);
		}

		update_matrices();

		__followObjectLast = FollowObject;

		return self;
	};
}
