/// @enum Enumeration of edit spaces.
enum BBMOD_EEditSpace
{
	/// @member Edit instances in world-space.
	Global,
	/// @member Edit instance relatively to its transformation.
	Local,
	/// @member Total number of members of this enum.
	SIZE,
};

/// @enum Enumeration of edit types.
enum BBMOD_EEditType
{
	/// @member Translate selected instances.
	Position,
	/// @member Rotate selected instances.
	Rotation,
	/// @member Scale selected instances.
	Scale,
	/// @member Total number of members of this enum.
	SIZE,
};

/// @enum Enumeration of edit axes.
enum BBMOD_EEditAxis
{
	/// @member No edit.
	None = 0,
	/// @member Edit on X axis.
	X = $1,
	/// @member Edit on Y axis.
	Y = $10,
	/// @member Edit on Z axis.
	Z = $100,
	/// @member Edit on all axes.
	All = $111,
};

/// @func BBMOD_Gizmo([_size])
///
/// @extends BBMOD_Class
///
/// @desc A gizmo for transforming instances.
///
/// @param {Real} [_size] The size of the gizmo. Default value is 10 units.
///
/// @note This requries synchronnous loading of models, therefore it cannot
/// be used on platforms like HTML5, which require asynchronnous loading.
/// You also **must** use {@link BBMOD_Camera} for the gizmo to work properly!
function BBMOD_Gizmo(_size=10.0)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

	/// @var {Array<Struct.BBMOD_Model>} Gizmo models for individual edit modes.
	/// @note Please note that these are not loaded asynchronnously, therefore
	/// the gizmo cannot be used on platforms that require asynchronnous loading,
	/// like HTML5!
	/// @see BBMOD_EEditType
	/// @readonly
	static Models = undefined;

	/// @var {Array<Struct.BBMOD_Material>} Materials used when mouse-picking
	/// the gizmo.
	static MaterialsSelect = undefined;

	if (Models == undefined)
	{
		var _shaderSelect = new BBMOD_BaseShader(
			BBMOD_ShGizmoSelect, BBMOD_VFORMAT_DEFAULT);
		var _materialSelect = new BBMOD_BaseMaterial(_shaderSelect);
		_materialSelect.BaseOpacity = sprite_get_texture(BBMOD_SprGizmo, 1);
		MaterialsSelect = [_materialSelect];

		var _shader = new BBMOD_BaseShader(BBMOD_ShGizmo, BBMOD_VFORMAT_DEFAULT);
		var _material = new BBMOD_BaseMaterial(_shader);
		_material.BaseOpacity = sprite_get_texture(BBMOD_SprGizmo, 0);

		var _modelMove = new BBMOD_Model("Data/BBMOD/Models/GizmoMove.bbmod")
			.freeze();
		// TODO: Fix gizmo model
		_modelMove.RootNode.Transform = new BBMOD_DualQuaternion();
		_modelMove.Materials[@ 0] = _material;

		var _modelScale = new BBMOD_Model("Data/BBMOD/Models/GizmoScale.bbmod")
			.freeze();
		_modelScale.Materials[@ 0] = _material;

		var _modelRotate = new BBMOD_Model("Data/BBMOD/Models/GizmoRotate.bbmod")
			.freeze();
		_modelRotate.Materials[@ 0] = _material;

		Models = [
			_modelMove,
			_modelRotate,
			_modelScale,
		];
	}

	/// @var {Bool} If `true` then the gizmo is editing selected instances.
	IsEditing = false;

	/// @var {Struct.BBMOD_Vec2} Screen-space coordinates to lock the mouse
	/// cursor at or `undefined`.
	/// @private
	__mouseLockAt = undefined;

	/// @var {Struct.BBMOD_Vec3} World-space offset from the mouse to the gizmo
	/// or `undefined`.
	/// @private
	__mouseOffset = undefined;

	/// @var {Constant.Cursor} The cursor used before editing started.
	/// @private
	__cursorBackup = undefined;

	/// @var {Bool} Enables snapping to grid when moving objects. Default value
	/// is `true`.
	/// @see BBMOD_Gizmo.GridSize
	EnableGridSnap = true;

	/// @var {Struct.BBMOD_Vec3} The size of the grid. Default value is
	/// `(1, 1, 1)`.
	/// @see BBMOD_Gizmo.EnableGridSnap
	GridSize = new BBMOD_Vec3(1.0);

	/// @var {Bool} Enables angle snapping when rotating objects. Default value
	/// is `true`.
	/// @see BBMOD_Gizmo.AngleSnap
	EnableAngleSnap = true;

	/// @var {Real} Angle snapping size. Default value is 1.
	/// @see BBMOD_Gizmo.EnableAngleSnap
	AngleSnap = 1.0;

	/// @var {Real} Determines the space in which are the selected instances
	/// transformed. Use values from {@link BBMOD_EEditSpace}.
	EditSpace = BBMOD_EEditSpace.Global;

	/// @var {Real} Determines how are the selected instances transformed
	/// (translated/rotated/scaled. Use values from {@link BBMOD_EEditType}.
	EditType = BBMOD_EEditType.Position;

	/// @var {Real} Determines on which axes are the selected instances edited.
	/// Use values from {@link BBMOD_EEditAxis}.
	EditAxis = BBMOD_EEditAxis.None;

	/// @var {Constant.MouseButton} The mouse button used for dragging the gizmo.
	/// Default is `mb_left`.
	ButtonDrag = mb_left;

	/// @var {Constant.VirtualKey} The virtual key used to switch to the next
	/// edit type. Default is `vk_tab`.
	/// @see BBMOD_Gizmo.EditType
	KeyNextEditType = vk_tab;

	/// @var {Constant.VirtualKey} The virtual key used to switch to the next
	/// edit space. Default is `vk_space`.
	/// @see BBMOD_Gizmo.EditSpace
	KeyNextEditSpace = vk_space;

	/// @var {Constant.VirtualKey} The virtual key used to increase
	/// speed of editing (e.g. rotate objects by a larger angle). Default is
	/// `vk_shift`.
	KeyEditFaster = vk_shift;

	/// @var {Constant.VirtualKey} The virtual key used to decrease
	/// speed of editing (e.g. rotate objects by a smaller angle). Default is
	/// `vk_control`.
	KeyEditSlower = vk_control;

	/// @var {Constant.VirtualKey} The virtual key used to cancel editing and
	/// revert changes. Default is `vk_escape`.
	KeyCancel = vk_escape;

	/// @var {Constant.VirtualKey} The virtual key used to ignore grid and
	/// angle snapping when they are enabled. Default is `vk_alt`.
	/// @see BBMOD_Gizmo.EnableGridSnap
	/// @see BBMOD_Gizmo.EnableAngleSnap
	KeyIgnoreSnap = vk_alt;

	/// @var {Real} The size of the gizmo. Default value is 10.
	Size = _size;

	/// @var {Struct.BBMOD_Vec3} The gizmo's position in world-space.
	/// @readonly
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The gizmo's position in world-space before
	/// editing started or `undefined`.
	/// @private
	__positionBackup = undefined;

	/// @var {Struct.BBMOD_Vec3} The gizmo's rotation in euler angles.
	Rotation = new BBMOD_Vec3();

	/// @var {Id.DsList<Id.Instance>} A list of selected instances.
	/// @readonly
	Selected = ds_list_create();

	/// @var {Id.DsList<Struct>} A list of additional data required for editing
	/// instances, e.g. their original offset from the gizmo, rotation and scale.
	/// @private
	__instanceData = ds_list_create();

	/// @var {Struct.BBMOD_Vec3} The current scaling factor of selected instances.
	/// @private
	__scaleBy = new BBMOD_Vec3(0.0);

	/// @var {Struct.BBMOD_Vec3} The current euler angles we are rotating selected
	/// instances by.
	/// @private
	__rotateBy = new BBMOD_Vec3(0.0);

	/// @var {Function} A function that the gizmo uses to check whether an instance
	/// exists. Must take the instance as the first argument and return a bool.
	/// Defaults a function that returns the result of `instance_exists`.
	InstanceExists = function (_instance) {
		gml_pragma("forceinline");
		return instance_exists(_instance);
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// global matrix. Normally this is an identity matrix. If the instance is
	/// attached to another instance for example, then this will be that
	/// instance's transformation matrix. Must take the instance as the first
	/// argument and return a {@link BBMOD_Matrix}. Defaults to a function that
	/// always returns an identity matrix.
	GetInstanceGlobalMatrix = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Matrix();
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// position on the X axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's `x`
	/// variable.
	GetInstancePositionX = function (_instance) {
		gml_pragma("forceinline");
		return _instance.x;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// position on the X axis. Must take the instance as the first argument and
	/// its new position on the X axis as the second argument. Defaults to a
	/// function that assings the new position to the instance's `x` variable.
	SetInstancePositionX = function (_instance, _x) {
		gml_pragma("forceinline");
		_instance.x = _x;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// position on the Y axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's `y`
	/// variable.
	GetInstancePositionY = function (_instance) {
		gml_pragma("forceinline");
		return _instance.y;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// position on the Y axis. Must take the instance as the first argument and
	/// its new position on the Y axis as the second argument. Defaults to a
	/// function that assings the new position to the instance's `y` variable.
	SetInstancePositionY = function (_instance, _y) {
		gml_pragma("forceinline");
		_instance.y = _y;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// position on the Z axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's `z`
	/// variable.
	GetInstancePositionZ = function (_instance) {
		gml_pragma("forceinline");
		return _instance.z;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// position on the Z axis. Must take the instance as the first argument and
	/// its new position on the Z axis as the second argument. Defaults to a
	/// function that assings the new position to the instance's `Z` variable.
	SetInstancePositionZ = function (_instance, _z) {
		gml_pragma("forceinline");
		_instance.z = _z;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// rotation on the X axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that always returns 0.
	GetInstanceRotationX = function (_instance) {
		gml_pragma("forceinline");
		return 0.0;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// rotation on the X axis. Must take the instance as the first argument and
	/// its new rotation on the X axis as the second argument. Defaults to a
	/// function that does not do anything.
	SetInstanceRotationX = function (_instance, _x) {
		gml_pragma("forceinline");
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// rotation on the Y axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that always returns 0.
	GetInstanceRotationY = function (_instance) {
		gml_pragma("forceinline");
		return 0.0;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// rotation on the Y axis. Must take the instance as the first argument and
	/// its new rotation on the Y axis as the second argument. Defaults to a
	/// function that does not do anything.
	SetInstanceRotationY = function (_instance, _y) {
		gml_pragma("forceinline");
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// rotation on the Z axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's
	/// `image_angle` variable.
	GetInstanceRotationZ = function (_instance) {
		gml_pragma("forceinline");
		return _instance.image_angle;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// rotation on the Z axis. Must take the instance as the first argument and
	/// its new rotation on the Z axis as the second argument. Defaults to a
	/// function that assings the new rotation to the instance's `image_angle`
	/// variable.
	SetInstanceRotationZ = function (_instance, _z) {
		gml_pragma("forceinline");
		_instance.image_angle = _z;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// scale on the X axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's
	/// `image_xscale` variable.
	GetInstanceScaleX = function (_instance) {
		gml_pragma("forceinline");
		return _instance.image_xscale;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// scale on the X axis. Must take the instance as the first argument and
	/// its new scale on the X axis as the second argument. Defaults to a
	/// function that assings the new scale to the instance's `image_xscale`
	/// variable.
	SetInstanceScaleX = function (_instance, _x) {
		gml_pragma("forceinline");
		_instance.image_xscale = _x;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// scale on the Y axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that returns the instance's
	/// `image_yscale` variable.
	GetInstanceScaleY = function (_instance) {
		gml_pragma("forceinline");
		return _instance.image_yscale;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// scale on the Y axis. Must take the instance as the first argument and
	/// its new scale on the Y axis as the second argument. Defaults to a
	/// function that assings the new scale to the instance's `image_yscale`
	/// variable.
	SetInstanceScaleY = function (_instance, _y) {
		gml_pragma("forceinline");
		_instance.image_yscale = _y;
	};

	/// @var {Function} A function that the gizmo uses to retrieve an instance's
	/// scale on the Z axis. Must take the instance as the first argument and
	/// return a real. Defaults to a function that always returns 1.
	GetInstanceScaleZ = function (_instance) {
		gml_pragma("forceinline");
		return 1.0;
	};

	/// @var {Function} A function that the gizmo uses to change an instance's
	/// scale on the Z axis. Must take the instance as the first argument and
	/// its new scale on the Z axis as the second argument. Defaults to a
	/// function that does not do anything.
	SetInstanceScaleZ = function (_instance, _z) {
		gml_pragma("forceinline");
	};

	/// @func get_instance_position_vec3(_instance)
	///
	/// @desc Retrieves an instance's position as {@link BBMOD_Vec3}.
	///
	/// @param {Id.Instance} _instance The ID of the instance.
	///
	/// @return {Struct.BBMOD_Vec3} The instance's position.
	static get_instance_position_vec3 = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstancePositionX(_instance),
			GetInstancePositionY(_instance),
			GetInstancePositionZ(_instance));
	};

	/// @func set_instance_position_vec3(_instance, _position)
	///
	/// @desc Changes an instance's position using a {@link BBMOD_Vec3}.
	///
	/// @param {Id.Instance} _instance The ID of the instance.
	/// @param {Struct.BBMOD_Vec3} _position The new position of the instance.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static set_instance_position_vec3 = function (_instance, _position) {
		gml_pragma("forceinline");
		SetInstancePositionX(_instance, _position.X);
		SetInstancePositionY(_instance, _position.Y);
		SetInstancePositionZ(_instance, _position.Z);
		return self;
	};

	/// @func get_instance_rotation_vec3(_instance)
	///
	/// @desc Retrieves an instance's rotation as {@link BBMOD_Vec3}.
	///
	/// @param {Id.Instance} _instance The ID of the instance.
	///
	/// @return {Struct.BBMOD_Vec3} The instance's rotation in euler angles.
	static get_instance_rotation_vec3 = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstanceRotationX(_instance),
			GetInstanceRotationY(_instance),
			GetInstanceRotationZ(_instance));
	};

	/// @func set_instance_rotation_vec3(_instance, _rotation)
	///
	/// @desc Changes an instance's rotation using a {@link BBMOD_Vec3}.
	///
	/// @param {Id.Instance} _instance The ID of the instance.
	/// @param {Struct.BBMOD_Vec3} _rotation The new rotation of the instance
	/// in euler angles.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static set_instance_rotation_vec3 = function (_instance, _rotation) {
		gml_pragma("forceinline");
		SetInstanceRotationX(_instance, _rotation.X);
		SetInstanceRotationY(_instance, _rotation.Y);
		SetInstanceRotationZ(_instance, _rotation.Z);
		return self;
	};

	/// @func get_instance_scale_vec3(_instance)
	///
	/// @desc Retrieves an instance's scale as {@link BBMOD_Vec3}.
	///
	/// @param {Id.Instance} _instance The ID of the instance.
	///
	/// @return {Struct.BBMOD_Vec3} The instance's scale.
	static get_instance_scale_vec3 = function (_instance) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			GetInstanceScaleX(_instance),
			GetInstanceScaleY(_instance),
			GetInstanceScaleZ(_instance));
	};

	/// @func set_instance_scale_vec3(_instance, _scale)
	///
	/// @desc Changes an instance's scale using a {@link BBMOD_Vec3}.
	///
	/// @param {Id.Instance} _instance The ID of the instance.
	/// @param {Struct.BBMOD_Vec3} _scale The new scale of the instance.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static set_instance_scale_vec3 = function (_instance, _scale) {
		gml_pragma("forceinline");
		SetInstanceScaleX(_instance, _scale.X);
		SetInstanceScaleY(_instance, _scale.Y);
		SetInstanceScaleZ(_instance, _scale.Z);
		return self;
	};

	/// @func select(_instance)
	///
	/// @desc Adds an instance to selection.
	///
	/// @param {Id.Instance} _instance The instance to select.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static select = function (_instance) {
		gml_pragma("forceinline");
		if (!is_selected(_instance))
		{
			ds_list_add(Selected, _instance);
			ds_list_add(__instanceData, {
				Offset: new BBMOD_Vec3(),
				Rotation: new BBMOD_Vec3(),
				Scale: new BBMOD_Vec3(),
			});
		}
		return self;
	};

	/// @func is_selected(_instance)
	///
	/// @desc Checks whether an instance is selected.
	///
	/// @param {Id.Instance} _instance The instance to check.
	///
	/// @return {Bool} Returns `true` if the instance is selected.
	static is_selected = function (_instance) {
		gml_pragma("forceinline");
		return (ds_list_find_index(Selected, _instance) != -1);
	};

	/// @func unselect(_instance)
	///
	/// @desc Removes an instance from selection.
	///
	/// @param {Id.Instance} _instance The instance to unselect.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static unselect = function (_instance) {
		gml_pragma("forceinline");
		var _index = ds_list_find_index(Selected, _instance);
		if (_index != -1)
		{
			ds_list_delete(Selected, _index);
			ds_list_delete(__instanceData, _index);
		}
		return self;
	};

	/// @func toggle_select(_instance)
	///
	/// @desc Unselects an instance if it's selected, or selects if it isn't.
	///
	/// @param {Id.Instance} _instance The instance to toggle selection of.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static toggle_select = function (_instance) {
		gml_pragma("forceinline");
		if (is_selected(_instance))
		{
			unselect(_instance);
		}
		else
		{
			select(_instance);
		}
		return self;
	};

	/// @func clear_selection()
	///
	/// @desc Removes all instances from selection.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static clear_selection = function () {
		gml_pragma("forceinline");
		ds_list_clear(Selected);
		ds_list_clear(__instanceData);
		return self;
	};

	/// @func intersect_ray_plane(_origin, _direction, _plane, _normal)
	///
	/// @desc Intersects a ray with a plane.
	///
	/// @param {Struct.BBMOD_Vec3} _origin The ray origin.
	/// @param {Struct.BBMOD_Vec3} _direction The ray direction.
	/// @param {Struct.BBMOD_Vec3} _plane The plane origin.
	/// @param {Struct.BBMOD_Vec3} _normal The plane normal.
	///
	/// @return {Struct.BBMOD_Vec3} The point of intersection or `undefined`.
	///
	/// @private
	static intersect_ray_plane = function (_origin, _direction, _plane, _normal) {
		var _dot = _direction.Dot(_normal);
		if (_dot == 0.0)
		{
			return undefined;
		}
		var _t = -(_origin.Sub(_plane).Dot(_normal) / _dot);
		return _origin.Add(_direction.Scale(_t));
	};

	/// @func update_position()
	///
	/// @desc Updates the gizmo's position, based on its selected instances.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	static update_position = function () {
		var _size = ds_list_size(Selected);
		var _posX = 0.0;
		var _posY = 0.0;
		var _posZ = 0.0;

		for (var i = _size - 1; i >= 0; --i)
		{
			var _instance = Selected[| i];

			if (!InstanceExists(_instance))
			{
				ds_list_delete(Selected, i);
				ds_list_delete(__instanceData, i);
				--_size;
				continue;
			}

			_posX += GetInstancePositionX(_instance);
			_posY += GetInstancePositionY(_instance);
			_posZ += GetInstancePositionZ(_instance);
		}

		if (_size > 0)
		{
			_posX /= _size;
			_posY /= _size;
			_posZ /= _size;

			Position.Set(_posX, _posY, _posZ);

			if (EditSpace == BBMOD_EEditSpace.Local)
			{
				var _lastSelected = Selected[| _size - 1];
				Rotation.Set(
					GetInstanceRotationX(_lastSelected),
					GetInstanceRotationY(_lastSelected),
					GetInstanceRotationZ(_lastSelected));
			}
			else
			{
				Rotation.Set(0.0, 0.0, 0.0);
			}
		}

		return self;
	};

	/// @func update(_deltaTime)
	///
	/// @desc Updates the gizmo. Should be called every frame.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	///
	/// @note This requires you to use a {@link BBMOD_BaseCamera} and it will
	/// not do anything if its [apply](./BBMOD_BaseCamera.apply.html) method has
	/// not been called yet!
	static update = function (_deltaTime) {
		if (!global.__bbmodCameraCurrent)
		{
			return self;
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Not editing or finished editing
		//
		if (!IsEditing || !mouse_check_button(ButtonDrag))
		{
			if (KeyNextEditType != undefined
				&& keyboard_check_pressed(KeyNextEditType))
			{
				if (++EditType >= BBMOD_EEditType.SIZE)
				{
					EditType = 0;
				}
			}

			if (KeyNextEditSpace != undefined
				&& keyboard_check_pressed(KeyNextEditSpace))
			{
				if (++EditSpace >= BBMOD_EEditSpace.SIZE)
				{
					EditSpace = 0;
				}
			}

			// Compute gizmo's new position
			var _size = ds_list_size(Selected);
			var _posX = 0.0;
			var _posY = 0.0;
			var _posZ = 0.0;

			for (var i = _size - 1; i >= 0; --i)
			{
				var _instance = Selected[| i];

				if (!InstanceExists(_instance))
				{
					ds_list_delete(Selected, i);
					ds_list_delete(__instanceData, i);
					--_size;
					continue;
				}

				_posX += GetInstancePositionX(_instance);
				_posY += GetInstancePositionY(_instance);
				_posZ += GetInstancePositionZ(_instance);
			}

			if (_size > 0)
			{
				_posX /= _size;
				_posY /= _size;
				_posZ /= _size;

				Position.Set(_posX, _posY, _posZ);

				if (EditSpace == BBMOD_EEditSpace.Local)
				{
					var _lastSelected = Selected[| _size - 1];
					var _mat = GetInstanceGlobalMatrix(_lastSelected);
					var _mat2 = new BBMOD_Matrix().RotateEuler(get_instance_rotation_vec3(_lastSelected));
					var _mat3 = _mat2.Mul(_mat);
					var _euler = _mat3.ToEuler();
					Rotation.FromArray(_euler);
				}
				else
				{
					Rotation.Set(0.0, 0.0, 0.0);
				}
			}

			// Store instance data
			for (var i = _size - 1; i >= 0; --i)
			{
				var _instance = Selected[| i];
				var _data = __instanceData[| i];
				_data.Offset = get_instance_position_vec3(_instance).Sub(Position);
				_data.Rotation = get_instance_rotation_vec3(_instance);
				_data.Scale = get_instance_scale_vec3(_instance);
			}

			// Clear properties used when editing
			IsEditing = false;
			__mouseOffset = undefined;
			__mouseLockAt = undefined;
			__positionBackup = undefined;
			if (__cursorBackup != undefined)
			{
				window_set_cursor(__cursorBackup);
				__cursorBackup = undefined;
			}
			__scaleBy = new BBMOD_Vec3(0.0);
			__rotateBy = new BBMOD_Vec3(0.0);

			return self;
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Editing
		//
		var _mouseX = window_mouse_get_x();
		var _mouseY = window_mouse_get_y();

		if (!__mouseLockAt)
		{
			__mouseLockAt = new BBMOD_Vec2(_mouseX, _mouseY);
			__cursorBackup = window_get_cursor();
		}

		var _quaternionGizmo = new BBMOD_Quaternion().FromEuler(Rotation.X, Rotation.Y, Rotation.Z);
		var _forwardGizmo    = _quaternionGizmo.Rotate(BBMOD_VEC3_FORWARD);
		var _rightGizmo      = _quaternionGizmo.Rotate(BBMOD_VEC3_RIGHT);
		var _upGizmo         = _quaternionGizmo.Rotate(BBMOD_VEC3_UP);

		var _matRot = [
			_forwardGizmo.X, _forwardGizmo.Y, _forwardGizmo.Z, 0.0,
			_rightGizmo.X,   _rightGizmo.Y,   _rightGizmo.Z,   0.0,
			_upGizmo.X,      _upGizmo.Y,      _upGizmo.Z,      0.0,
			0.0,             0.0,             0.0,             1.0,
		];

		var _matRotInverse = [
			_forwardGizmo.X, _rightGizmo.X, _upGizmo.X, 0.0,
			_forwardGizmo.Y, _rightGizmo.Y, _upGizmo.Y, 0.0,
			_forwardGizmo.Z, _rightGizmo.Z, _upGizmo.Z, 0.0,
			0.0,             0.0,           0.0,        1.0,
		];

		////////////////////////////////////////////////////////////////////////
		// Handle editing
		switch (EditType)
		{
		case BBMOD_EEditType.Position:
			if (!__positionBackup)
			{
				__positionBackup = Position.Clone();
			}

			var _planeNormal;

			switch (EditAxis)
			{
			case BBMOD_EEditAxis.X:
				var _dot1 = _rightGizmo.Dot(global.__bbmodCameraCurrent.get_forward());
				var _dot2 = _upGizmo.Dot(global.__bbmodCameraCurrent.get_forward());
				_planeNormal = (abs(_dot1) > abs(_dot2)) ? _rightGizmo : _upGizmo;
				break;

			case BBMOD_EEditAxis.Y:
				var _dot1 = _forwardGizmo.Dot(global.__bbmodCameraCurrent.get_forward());
				var _dot2 = _upGizmo.Dot(global.__bbmodCameraCurrent.get_forward());
				_planeNormal = (abs(_dot1) > abs(_dot2)) ? _forwardGizmo : _upGizmo;
				break;

			case BBMOD_EEditAxis.Z:
				var _dot1 = _forwardGizmo.Dot(global.__bbmodCameraCurrent.get_forward());
				var _dot2 = _rightGizmo.Dot(global.__bbmodCameraCurrent.get_forward());
				_planeNormal = (abs(_dot1) > abs(_dot2)) ? _forwardGizmo : _rightGizmo;
				break;

			case BBMOD_EEditAxis.All:
				_planeNormal = global.__bbmodCameraCurrent.get_forward();
				break;
			}

			var _mouseWorld = intersect_ray_plane(
				global.__bbmodCameraCurrent.Position,
				global.__bbmodCameraCurrent.screen_point_to_vec3(new BBMOD_Vec2(_mouseX, _mouseY), global.__bbmodRendererCurrent),
				__positionBackup,
				_planeNormal);

			if (_mouseWorld)
			{
				var _snap = (EnableGridSnap && !keyboard_check(KeyIgnoreSnap));

				if (EditAxis == BBMOD_EEditAxis.All)
				{
					if (!__mouseOffset)
					{
						__mouseOffset = _mouseWorld.Sub(Position);
					}

					Position = _mouseWorld.Add(__mouseOffset);
				}
				else
				{
					if (!__mouseOffset)
					{
						__mouseOffset = _mouseWorld;
					}

					var _diff = _mouseWorld.Sub(__mouseOffset);

					if (EditAxis & BBMOD_EEditAxis.X)
					{
						var _moveX = _forwardGizmo.Scale(_diff.Dot(_forwardGizmo));
						if (_snap
							&& EditSpace == BBMOD_EEditSpace.Local
							&& GridSize.X != 0.0)
						{
							var _moveXLength = _moveX.Length();
							if (_moveXLength > 0.0)
							{
								var _s = round(_moveXLength / GridSize.X) * GridSize.X;
								_moveX = _moveX.Normalize().Scale(_s);
							}
						}
						Position = __positionBackup.Add(_moveX);
					}

					if (EditAxis & BBMOD_EEditAxis.Y)
					{
						var _moveY = _rightGizmo.Scale(_diff.Dot(_rightGizmo));
						if (_snap
							&& EditSpace == BBMOD_EEditSpace.Local
							&& GridSize.Y != 0.0)
						{
							var _moveYLength = _moveY.Length();
							if (_moveYLength > 0.0)
							{
								var _s = round(_moveYLength / GridSize.Y) * GridSize.Y;
								_moveY = _moveY.Normalize().Scale(_s);
							}
						}
						Position = __positionBackup.Add(_moveY);
					}

					if (EditAxis & BBMOD_EEditAxis.Z)
					{
						var _moveZ = _upGizmo.Scale(_diff.Dot(_upGizmo));
						if (_snap
							&& EditSpace == BBMOD_EEditSpace.Local
							&& GridSize.Z != 0.0)
						{
							var _moveZLength = _moveZ.Length();
							if (_moveZLength > 0.0)
							{
								var _s = round(_moveZLength / GridSize.Z) * GridSize.Z;
								_moveZ = _moveZ.Normalize().Scale(_s);
							}
						}
						Position = __positionBackup.Add(_moveZ);
					}
				}

				if (_snap
					&& (EditSpace == BBMOD_EEditSpace.Global
					|| EditAxis == BBMOD_EEditAxis.All))
				{
					if (GridSize.X != 0.0)
					{
						Position.X = round(Position.X / GridSize.X) * GridSize.X;
					}

					if (GridSize.Y != 0.0)
					{
						Position.Y = round(Position.Y / GridSize.Y) * GridSize.Y;
					}

					if (GridSize.Z != 0.0)
					{
						Position.Z = round(Position.Z / GridSize.Z) * GridSize.Z;
					}
				}
			}
			break;

		case BBMOD_EEditType.Rotation:
			var _planeNormal = ((EditAxis == BBMOD_EEditAxis.X) ? _forwardGizmo
				: ((EditAxis == BBMOD_EEditAxis.Y) ? _rightGizmo
				: _upGizmo));

			var _mouseWorld = intersect_ray_plane(
				global.__bbmodCameraCurrent.Position,
				global.__bbmodCameraCurrent.screen_point_to_vec3(new BBMOD_Vec2(_mouseX, _mouseY), global.__bbmodRendererCurrent),
				Position,
				_planeNormal);

			if (_mouseWorld)
			{
				if (!__mouseOffset)
				{
					__mouseOffset = _mouseWorld;
				}

				var _v1 = __mouseOffset.Sub(Position);
				var _v2 = _mouseWorld.Sub(Position);
				var _angle = darctan2(_v2.Cross(_v1).Dot(_planeNormal), _v1.Dot(_v2));

				switch (EditAxis)
				{
				case BBMOD_EEditAxis.X:
					__rotateBy.X = _angle;
					break;

				case BBMOD_EEditAxis.Y:
					__rotateBy.Y = _angle;
					break;

				case BBMOD_EEditAxis.Z:
					__rotateBy.Z = _angle;
					break;
				}
			}
			break;

		case BBMOD_EEditType.Scale:
			var _planeNormal;

			switch (EditAxis)
			{
			case BBMOD_EEditAxis.X:
				var _dot1 = _rightGizmo.Dot(global.__bbmodCameraCurrent.get_forward());
				var _dot2 = _upGizmo.Dot(global.__bbmodCameraCurrent.get_forward());
				_planeNormal = (abs(_dot1) > abs(_dot2)) ? _rightGizmo : _upGizmo;
				break;

			case BBMOD_EEditAxis.Y:
				var _dot1 = _forwardGizmo.Dot(global.__bbmodCameraCurrent.get_forward());
				var _dot2 = _upGizmo.Dot(global.__bbmodCameraCurrent.get_forward());
				_planeNormal = (abs(_dot1) > abs(_dot2)) ? _forwardGizmo : _upGizmo;
				break;

			case BBMOD_EEditAxis.Z:
				var _dot1 = _forwardGizmo.Dot(global.__bbmodCameraCurrent.get_forward());
				var _dot2 = _rightGizmo.Dot(global.__bbmodCameraCurrent.get_forward());
				_planeNormal = (abs(_dot1) > abs(_dot2)) ? _forwardGizmo : _rightGizmo;
				break;

			case BBMOD_EEditAxis.All:
				_planeNormal = global.__bbmodCameraCurrent.get_forward();
				break;
			}

			var _mouseWorld = intersect_ray_plane(
				global.__bbmodCameraCurrent.Position,
				global.__bbmodCameraCurrent.screen_point_to_vec3(new BBMOD_Vec2(_mouseX, _mouseY), global.__bbmodRendererCurrent),
				Position,
				_planeNormal);

			if (_mouseWorld && __mouseOffset)
			{
				var _mul = (keyboard_check(KeyEditFaster) ? 5.0
					: (keyboard_check(KeyEditSlower) ? 0.1
					: 1.0));

				var _diff = _mouseWorld.Sub(__mouseOffset).Scale(_mul);

				if (EditAxis == BBMOD_EEditAxis.All)
				{
					var _diffX = _diff.Mul(_forwardGizmo.Abs()).Dot(_forwardGizmo);
					var _diffY = _diff.Mul(_rightGizmo.Abs()).Dot(_rightGizmo);
					var _scaleBy = (abs(_diffX) > abs(_diffY)) ? _diffX : _diffY;
					__scaleBy.X += _scaleBy;
					__scaleBy.Y += _scaleBy;
					__scaleBy.Z += _scaleBy;
				}
				else
				{
					if (EditAxis & BBMOD_EEditAxis.X)
					{
						__scaleBy.X += _diff.Mul(_forwardGizmo.Abs()).Dot(_forwardGizmo);
					}

					if (EditAxis & BBMOD_EEditAxis.Y)
					{
						__scaleBy.Y += _diff.Mul(_rightGizmo.Abs()).Dot(_rightGizmo);
					}

					if (EditAxis & BBMOD_EEditAxis.Z)
					{
						__scaleBy.Z += _diff.Mul(_upGizmo.Abs()).Dot(_upGizmo);
					}
				}
			}

			__mouseOffset = _mouseWorld;
			break;
		}

		////////////////////////////////////////////////////////////////////////
		// Cancel editing?
		if (keyboard_check_pressed(KeyCancel))
		{
			if (__positionBackup)
			{
				__positionBackup.Copy(Position);
			}
			__rotateBy.Set(0.0, 0.0, 0.0);
			__scaleBy.Set(0.0, 0.0, 0.0);
			IsEditing = false;
		}

		////////////////////////////////////////////////////////////////////////
		// Apply to selected instances
		var _size = ds_list_size(Selected);

		for (var i = _size - 1; i >= 0; --i)
		{
			var _instance = Selected[| i];

			if (!InstanceExists(_instance))
			{
				ds_list_delete(Selected, i);
				ds_list_delete(__instanceData, i);
				--_size;
				continue;
			}

			var _data = __instanceData[| i];
			var _positionOffset = _data.Offset;
			var _rotationStored = _data.Rotation;
			var _scaleStored = _data.Scale;

			// Get local basis
			var _quaternionInstance = new BBMOD_Quaternion().FromEuler(
				GetInstanceRotationX(_instance),
				GetInstanceRotationY(_instance),
				GetInstanceRotationZ(_instance));
			var _forwardInstance    = _quaternionInstance.Rotate(BBMOD_VEC3_FORWARD);
			var _rightInstance      = _quaternionInstance.Rotate(BBMOD_VEC3_RIGHT);
			var _upInstance         = _quaternionInstance.Rotate(BBMOD_VEC3_UP);

			// Apply rotation
			var _matGlobal    = GetInstanceGlobalMatrix(_instance);
			var _matGlobalInv = _matGlobal.Inverse();
			var _rotateByX    = __rotateBy.X;
			var _rotateByY    = __rotateBy.Y;
			var _rotateByZ    = __rotateBy.Z;

			if (EnableAngleSnap
				&& AngleSnap != 0.0
				&& !keyboard_check(KeyIgnoreSnap))
			{
				_rotateByX = floor(__rotateBy.X / AngleSnap) * AngleSnap;
				_rotateByY = floor(__rotateBy.Y / AngleSnap) * AngleSnap;
				_rotateByZ = floor(__rotateBy.Z / AngleSnap) * AngleSnap;
			}

			var _temp          = new BBMOD_Vec4(_forwardGizmo.X, _forwardGizmo.Y, _forwardGizmo.Z, 0.0).Transform(_matGlobalInv.Raw);
			var _forwardGlobal = new BBMOD_Vec3(_temp.X, _temp.Y, _temp.Z);
			var _temp          = new BBMOD_Vec4(_rightGizmo.X, _rightGizmo.Y, _rightGizmo.Z, 0.0).Transform(_matGlobalInv.Raw);
			var _rightGlobal   = new BBMOD_Vec3(_temp.X, _temp.Y, _temp.Z);
			var _temp          = new BBMOD_Vec4(_upGizmo.X, _upGizmo.Y, _upGizmo.Z, 0.0).Transform(_matGlobalInv.Raw);
			var _upGlobal      = new BBMOD_Vec3(_temp.X, _temp.Y, _temp.Z);

			var _rotMatrix = new BBMOD_Matrix().RotateEuler(_rotationStored);
			if (_rotateByX != 0.0)
			{
				var _quaternionX = new BBMOD_Quaternion().FromAxisAngle(_forwardGlobal, _rotateByX);
				_positionOffset = _quaternionX.Rotate(_positionOffset);
				_rotMatrix = _rotMatrix.RotateQuat(_quaternionX);
			}
			if (_rotateByY != 0.0)
			{
				var _quaternionY = new BBMOD_Quaternion().FromAxisAngle(_rightGlobal, _rotateByY);
				_positionOffset = _quaternionY.Rotate(_positionOffset);
				_rotMatrix = _rotMatrix.RotateQuat(_quaternionY);
			}
			if (_rotateByZ != 0.0)
			{
				var _quaternionZ = new BBMOD_Quaternion().FromAxisAngle(_upGlobal, _rotateByZ);
				_positionOffset = _quaternionZ.Rotate(_positionOffset);
				_rotMatrix = _rotMatrix.RotateQuat(_quaternionZ);
			}
			var _rotArray = _rotMatrix.ToEuler();
			SetInstanceRotationX(_instance, _rotArray[0]);
			SetInstanceRotationY(_instance, _rotArray[1]);
			SetInstanceRotationZ(_instance, _rotArray[2]);

			// Apply scale
			var _scaleNew = _scaleStored.Clone();
			var _scaleOld = _scaleNew.Clone();

			// Scale on X
			_scaleNew.X += __scaleBy.X * abs(_forwardGlobal.Dot(_forwardInstance));
			_scaleNew.Y += __scaleBy.X * abs(_forwardGlobal.Dot(_rightInstance));
			_scaleNew.Z += __scaleBy.X * abs(_forwardGlobal.Dot(_upInstance));

			// Scale on Y
			_scaleNew.X += __scaleBy.Y * abs(_rightGlobal.Dot(_forwardInstance));
			_scaleNew.Y += __scaleBy.Y * abs(_rightGlobal.Dot(_rightInstance));
			_scaleNew.Z += __scaleBy.Y * abs(_rightGlobal.Dot(_upInstance));

			// Scale on Z
			_scaleNew.X += __scaleBy.Z * abs(_upGlobal.Dot(_forwardInstance));
			_scaleNew.Y += __scaleBy.Z * abs(_upGlobal.Dot(_rightInstance));
			_scaleNew.Z += __scaleBy.Z * abs(_upGlobal.Dot(_upInstance));

			// Scale offset
			var _vI = matrix_transform_vertex(_matRotInverse, _positionOffset.X, _positionOffset.Y, _positionOffset.Z);
			var _vIRot = matrix_transform_vertex(
				matrix_build(
					0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
					(1.0 / max(_scaleOld.X, 0.0001)) * (_scaleOld.X + __scaleBy.X),
					(1.0 / max(_scaleOld.Y, 0.0001)) * (_scaleOld.Y + __scaleBy.Y),
					(1.0 / max(_scaleOld.Z, 0.0001)) * (_scaleOld.Z + __scaleBy.Z)),
				_vI[0], _vI[1], _vI[2]);
			var _v = matrix_transform_vertex(_matRot, _vIRot[0], _vIRot[1], _vIRot[2]);

			// Apply scale and position
			set_instance_scale_vec3(_instance, _scaleNew);
			SetInstancePositionX(_instance, Position.X + _v[0]);
			SetInstancePositionY(_instance, Position.Y + _v[1]);
			SetInstancePositionZ(_instance, Position.Z + _v[2]);
		}

		return self;
	};

	/// @func submit([_materials])
	///
	/// @desc Immediately submits the gizmo for rendering.
	///
	/// @param {Array<Struct.BBMOD_Material>} [_materials] Materials to use or
	/// `undefined`.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	///
	/// @note This changes the world matrix based on the gizmo's position and size!
	static submit = function (_materials=undefined) {
		gml_pragma("forceinline");
		(new BBMOD_Matrix())
			.Scale(new BBMOD_Vec3(Size))
			.RotateEuler(Rotation)
			.Translate(Position)
			.ApplyWorld();
		Models[EditType].submit(_materials);
		return self;
	};

	/// @func render([_materials])
	///
	/// @desc Enqueues the gizmo for rendering.
	///
	/// @param {Array<Struct.BBMOD_Material>} [_materials] Materials to use or
	/// `undefined`.
	///
	/// @return {Struct.BBMOD_Gizmo} Returns `self`.
	///
	/// @note This changes the world matrix based on the gizmo's position and size!
	static render = function (_materials=undefined) {
		gml_pragma("forceinline");
		new BBMOD_Matrix()
			.Scale(new BBMOD_Vec3(Size))
			.RotateEuler(Rotation)
			.Translate(Position)
			.ApplyWorld();
		Models[EditType].render(_materials);
		return self;
	};

	static destroy = function () {
		Class_destroy();
		ds_list_destroy(Selected);
		ds_list_destroy(__instanceData);
		return undefined;
	};
}
